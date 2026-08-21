"""Gate-2 data-correctness tests for the Poplar fixture ledger (Stage 1).

Verifies the binding invariants from ops/specs/VERIFICATION_RELEASE_GATES.md
Gate 2: idempotency, tenant isolation, append-only, duplicate rejection,
and audit-trail completeness. Fixture data only (D-005).
"""
import os
import sys
import tempfile
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "src"))

from ledger import Ledger, LedgerError  # noqa: E402


@pytest.fixture()
def ledger(tmp_path):
    """A fresh ledger with a seeded tenant spine (two merchants)."""
    l = Ledger(str(tmp_path / "fixture.sqlite3"))
    l._conn.execute("INSERT INTO organizations VALUES ('o1','Poplar','America/Chicago','active','now','now')")
    l._conn.execute("INSERT INTO merchants VALUES ('m1','o1','Fixture Cafe','123 Fictional St','{}','','','authorized','{}','now')")
    l._conn.execute("INSERT INTO merchants VALUES ('m2','o1','Fixture Bakery','456 Fictional Ave','{}','','','authorized','{}','now')")
    l._conn.commit()
    yield l
    l.close()


# --- idempotency (FR-404) ---------------------------------------------------

def test_duplicate_idempotency_key_is_noop(ledger):
    e1 = ledger.append_event("scan", "fixture.customer", "idem-1", merchant_id="m1")
    e2 = ledger.append_event("scan", "fixture.customer", "idem-1", merchant_id="m1")
    assert e1["id"] == e2["id"], "duplicate submission must return the existing event"
    assert ledger.count() == 1, "duplicate must not create a second row"


def test_different_keys_create_distinct_events(ledger):
    e1 = ledger.append_event("scan", "c", "idem-A", merchant_id="m1")
    e2 = ledger.append_event("stamp", "s", "idem-B", merchant_id="m1")
    assert e1["id"] != e2["id"]
    assert ledger.count() == 2


# --- append-only (FR-401, FR-403) -------------------------------------------

def test_events_cannot_be_updated(ledger):
    ledger.append_event("scan", "c", "idem-1", merchant_id="m1")
    with pytest.raises(Exception) as e:  # sqlite3.IntegrityError from trigger
        ledger._conn.execute("UPDATE events SET kind='stamp' WHERE idempotency_key='idem-1'")
    assert "append-only" in str(e.value)


def test_events_cannot_be_deleted(ledger):
    ledger.append_event("scan", "c", "idem-1", merchant_id="m1")
    with pytest.raises(Exception) as e:
        ledger._conn.execute("DELETE FROM events WHERE idempotency_key='idem-1'")
    assert "append-only" in str(e.value)


def test_correction_is_compensating_event_not_edit(ledger):
    # FR-403: a correction is a new exception event, never an UPDATE
    ledger.append_event("redemption", "s", "idem-1", merchant_id="m1")
    ledger.append_event("exception", "s", "idem-2", merchant_id="m1",
                        payload={"correction_of": "idem-1", "reason": "void"})
    kinds = [e["kind"] for e in ledger.read_events(merchant_id="m1")]
    assert "exception" in kinds, "correction must be a compensating event"
    assert ledger.count() == 2, "no destructive edit occurred"


# --- tenant isolation (FR-203) -----------------------------------------------

def test_merchant_sees_only_own_events(ledger):
    ledger.append_event("scan", "c", "idem-1", merchant_id="m1")
    ledger.append_event("stamp", "s", "idem-2", merchant_id="m2")
    assert len(ledger.tenant_events_for_merchant("m1")) == 1
    assert len(ledger.tenant_events_for_merchant("m2")) == 1
    # no cross-merchant leakage
    m1_events = ledger.tenant_events_for_merchant("m1")
    assert all(e["merchant_id"] == "m1" for e in m1_events)


def test_cross_merchant_query_returns_nothing(ledger):
    ledger.append_event("scan", "c", "idem-1", merchant_id="m1")
    # a merchant querying for a different merchant's data gets nothing
    assert ledger.read_events(merchant_id="m1", campaign_id="nonexistent") == []


# --- validation (fail-closed) -------------------------------------------------

def test_unknown_event_kind_rejected(ledger):
    with pytest.raises(LedgerError):
        ledger.append_event("bogus", "c", "idem-1")


# --- audit completeness (Gate 2) ---------------------------------------------

def test_all_events_ledgered_with_provenance(ledger):
    ledger.append_event("scan", "fixture.customer", "idem-1", merchant_id="m1",
                        payload={"source": "qr/AB7K29"})
    events = ledger.read_events(merchant_id="m1")
    assert len(events) == 1
    e = events[0]
    for field in ("id", "kind", "actor_source", "timestamp", "idempotency_key"):
        assert e.get(field), f"missing provenance field: {field}"
