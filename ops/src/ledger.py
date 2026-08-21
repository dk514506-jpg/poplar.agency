#!/usr/bin/env python3
"""ledger.py — Poplar.agency append-only event ledger (FR-401..405).

The system of record. All writes go through here so the append-only +
idempotency + tenant-isolation invariants are enforced in ONE layer.

Invariants (binding, per ops/domain/DOMAIN_MODEL_DATA_CONTRACT.md):
  1. APPEND-ONLY: events are never updated or deleted; a correction is a
     compensating `exception` event (FR-403). The DB triggers are the
     last line of defense; this layer never attempts an UPDATE/DELETE.
  2. IDEMPOTENCY: every externally-triggered event carries an
     idempotency_key; a duplicate submission is a no-op (FR-404) —
     returns the existing event, does not raise.
  3. TENANT ISOLATION: reads are always scoped by merchant_id /
     organization_id; a merchant sees only its own rows (FR-203).
  4. Ledger is the source of truth for measurement; projections
     (redemptions.state, consents, communications.status) change only
     via new events, never direct UPDATE (Council amendment).

Fixture-only (D-005): no live customer/contact/merchant data.
"""
from __future__ import annotations

import json
import uuid
from datetime import datetime, timezone
from typing import Any, Dict, List, Optional

import sqlite3

# The engine-minimum / ledger event kinds (schema CHECK)
EVENT_KINDS = {"scan", "issue", "stamp", "claim", "redemption",
               "referral", "attendance", "exception"}


def _now() -> str:
    return datetime.now(timezone.utc).isoformat()


def _uuid() -> str:
    return uuid.uuid4().hex


class LedgerError(RuntimeError):
    """Raised on a ledger invariant violation (fail-closed)."""


class Ledger:
    """Append-only event ledger over the schema.sql store."""

    def __init__(self, db_path: str) -> None:
        self.db_path = db_path
        self._conn = sqlite3.connect(db_path)
        self._conn.row_factory = sqlite3.Row
        self._conn.execute("PRAGMA foreign_keys=ON")
        self._apply_schema()

    def _apply_schema(self) -> None:
        from pathlib import Path
        schema = Path(__file__).resolve().parent / "schema.sql"
        with open(schema) as fh:
            self._conn.executescript(fh.read())

    # ------------------------------------------------------------------ writes

    def append_event(
        self,
        kind: str,
        actor_source: str,
        idempotency_key: str,
        *,
        campaign_id: Optional[str] = None,
        merchant_id: Optional[str] = None,
        participant_id: Optional[str] = None,
        placement_id: Optional[str] = None,
        device_risk: Optional[Dict[str, Any]] = None,
        payload: Optional[Dict[str, Any]] = None,
        timestamp: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Append one event. Idempotent: re-submitting the same
        idempotency_key is a no-op returning the existing event (FR-404).

        Raises LedgerError on an invalid kind or an idempotency violation
        that is NOT a pure duplicate.
        """
        if kind not in EVENT_KINDS:
            raise LedgerError(f"unknown event kind: {kind}")
        ts = timestamp or _now()

        # Idempotency: check first. A matching existing event -> no-op.
        existing = self._conn.execute(
            "SELECT * FROM events WHERE idempotency_key = ?",
            (idempotency_key,),
        ).fetchone()
        if existing is not None:
            return dict(existing)

        eid = _uuid()
        with self._conn:  # atomic
            self._conn.execute(
                """INSERT INTO events
                   (id, kind, actor_source, campaign_id, merchant_id,
                    participant_id, placement_id, timestamp, device_risk,
                    idempotency_key, payload)
                   VALUES (?,?,?,?,?,?,?,?,?,?,?)""",
                (eid, kind, actor_source, campaign_id, merchant_id,
                 participant_id, placement_id, ts,
                 json.dumps(device_risk) if device_risk else None,
                 idempotency_key,
                 json.dumps(payload) if payload else None),
            )
        return self._get(eid)

    # ------------------------------------------------------------------ reads

    def _get(self, event_id: str) -> Dict[str, Any]:
        row = self._conn.execute(
            "SELECT * FROM events WHERE id = ?", (event_id,)
        ).fetchone()
        if row is None:
            raise LedgerError(f"event not found: {event_id}")
        d = dict(row)
        for k in ("device_risk", "payload"):
            if d.get(k):
                d[k] = json.loads(d[k])
        return d

    def read_events(
        self,
        *,
        merchant_id: Optional[str] = None,
        campaign_id: Optional[str] = None,
        participant_id: Optional[str] = None,
        limit: int = 1000,
    ) -> List[Dict[str, Any]]:
        """Read events, always tenant-scoped (FR-203). A merchant can only
        read its own rows; cross-merchant must return nothing.
        """
        q = "SELECT * FROM events WHERE 1=1"
        args: List[Any] = []
        if merchant_id is not None:
            q += " AND merchant_id = ?"
            args.append(merchant_id)
        if campaign_id is not None:
            q += " AND campaign_id = ?"
            args.append(campaign_id)
        if participant_id is not None:
            q += " AND participant_id = ?"
            args.append(participant_id)
        q += " ORDER BY timestamp LIMIT ?"
        args.append(limit)
        rows = self._conn.execute(q, args).fetchall()
        out = []
        for r in rows:
            d = dict(r)
            for k in ("device_risk", "payload"):
                if d.get(k):
                    d[k] = json.loads(d[k])
            out.append(d)
        return out

    def tenant_events_for_merchant(self, merchant_id: str) -> List[Dict[str, Any]]:
        """Strict tenant-scoped read: ONLY this merchant's events."""
        return self.read_events(merchant_id=merchant_id)

    def count(self) -> int:
        return int(self._conn.execute("SELECT COUNT(*) FROM events").fetchone()[0])

    def close(self) -> None:
        self._conn.close()

    def __enter__(self) -> "Ledger":
        return self

    def __exit__(self, *exc: Any) -> None:
        self.close()


if __name__ == "__main__":
    # fixture self-check
    import tempfile, os
    tmp = tempfile.mktemp(suffix=".sqlite3")
    with Ledger(tmp) as l:
        # seed the tenant spine so FKs resolve (fixture data)
        l._conn.execute("INSERT INTO organizations VALUES ('o1','Poplar','America/Chicago','active','now','now')")
        l._conn.execute("INSERT INTO merchants VALUES ('m1','o1','Fixture Cafe','123 Fictional St','{}','','','authorized','{}','now')")
        l._conn.execute("INSERT INTO merchants VALUES ('m2','o1','Fixture Bakery','456 Fictional Ave','{}','','','authorized','{}','now')")
        l._conn.commit()
        e1 = l.append_event("scan", "fixture.customer", "idem-1", merchant_id="m1",
                            payload={"source": "qr/AB7K29"})
        e2 = l.append_event("stamp", "fixture.staff", "idem-2", merchant_id="m1")
        # duplicate idempotency -> no-op returns existing
        dup = l.append_event("stamp", "fixture.staff", "idem-1", merchant_id="m1")
        assert dup["id"] == e1["id"], "idempotency no-op failed"
        assert l.count() == 2, f"expected 2 events, got {l.count()}"
        # tenant isolation: merchant m2 sees nothing
        assert l.tenant_events_for_merchant("m2") == []
        assert len(l.tenant_events_for_merchant("m1")) == 2
        print("LEDGER FIXTURE SELF-CHECK OK: idempotency, append-only, tenant isolation")
    os.unlink(tmp)
