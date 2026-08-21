-- Poplar.agency — Fixture schema + append-only event ledger (v0.1)
-- Implements the domain model (ops/domain/DOMAIN_MODEL_DATA_CONTRACT.md).
-- Status: FIXTURE BUILD, Stage 1. Fixture/demo data only (D-005); no live data.
--
-- Design invariants (binding):
--  1. APPEND-ONLY event ledger: the events table is the system of record.
--     No UPDATE/DELETE on events; corrections are compensating events (FR-403).
--  2. IDEMPOTENCY: every externally-triggered event carries a UNIQUE
--     idempotency_key; a duplicate submission is a no-op (FR-404).
--  3. TENANT ISOLATION: every business entity carries merchant_id/
--     organization_id; cross-merchant access must return nothing (FR-203).
--  4. Stateful tables are PROJECTIONS of the ledger (Council amendment):
--     redemptions.state, consents, communications.status change only via
--     new events, never UPDATE.
--
-- Fixture data is labeled DEMO/NOT LIVE; names fictionalized per the
-- public/internal classification (real merchant names never committed).

PRAGMA journal_mode = WAL;
PRAGMA foreign_keys = ON;

-- ---------------------------------------------------------------------------
-- Organizations / Users / Merchants (tenant spine)
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS organizations (
    id          TEXT PRIMARY KEY,            -- opaque UUID
    legal_name  TEXT NOT NULL,
    timezone    TEXT NOT NULL,
    status      TEXT NOT NULL CHECK (status IN ('draft','active','inactive')),
    created_at  TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
    updated_at  TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

CREATE TABLE IF NOT EXISTS users (
    id              TEXT PRIMARY KEY,
    organization_id TEXT NOT NULL REFERENCES organizations(id),
    merchant_id     TEXT REFERENCES merchants(id),  -- NULL for operator/admin; scopes merchant_champion (Council)
    email           TEXT NOT NULL,
    role            TEXT NOT NULL CHECK (role IN ('operator','admin','merchant_champion','merchant_staff','auditor')),
    mfa_enabled     INTEGER NOT NULL DEFAULT 0 CHECK (mfa_enabled IN (0,1)),
    status          TEXT NOT NULL CHECK (status IN ('active','disabled')),
    created_at      TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

CREATE TABLE IF NOT EXISTS merchants (
    id              TEXT PRIMARY KEY,
    organization_id TEXT NOT NULL REFERENCES organizations(id),
    name            TEXT NOT NULL,
    address         TEXT NOT NULL,
    hours           TEXT,                      -- JSON
    capacity_notes  TEXT,
    pos_system      TEXT,
    permission_state TEXT NOT NULL DEFAULT 'lead'
                    CHECK (permission_state IN ('lead','permissioned_example','authorized')),
    contact         TEXT,                      -- JSON (encrypted at rest in prod)
    created_at      TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

-- ---------------------------------------------------------------------------
-- Campaigns / Offers / Briefs / Templates / Placements
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS campaigns (
    id              TEXT PRIMARY KEY,
    name            TEXT NOT NULL,
    neighborhood    TEXT NOT NULL,
    objective       TEXT NOT NULL,
    hypothesis      TEXT,
    baseline_control TEXT,                     -- JSON; hash-pinned at Gate 0
    status          TEXT NOT NULL DEFAULT 'discover'
                    CHECK (status IN ('discover','design','approve','launch','operate','reconcile','learn','archive','halt')),
    version         INTEGER NOT NULL DEFAULT 1,
    owner_id        TEXT REFERENCES users(id),
    budget          TEXT,                      -- JSON
    start_date      TEXT,
    end_date        TEXT,
    created_at      TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
    updated_at      TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

CREATE TABLE IF NOT EXISTS campaign_merchants (
    id              TEXT PRIMARY KEY,
    campaign_id     TEXT NOT NULL REFERENCES campaigns(id),
    merchant_id     TEXT NOT NULL REFERENCES merchants(id),
    role            TEXT,
    offer_id        TEXT REFERENCES offers(id),
    capacity_window TEXT,                      -- JSON
    approved_copy   TEXT,
    economics       TEXT,                      -- JSON (merchant-approved margin snapshot)
    approval_state  TEXT NOT NULL DEFAULT 'pending'
                    CHECK (approval_state IN ('pending','approved','declined')),
    created_at      TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

CREATE TABLE IF NOT EXISTS offers (
    id             TEXT PRIMARY KEY,
    campaign_id    TEXT NOT NULL REFERENCES campaigns(id),
    merchant_id    TEXT NOT NULL REFERENCES merchants(id),
    title          TEXT NOT NULL,
    validity_window TEXT,                      -- JSON
    min_spend      REAL,
    exclusions     TEXT,                       -- JSON
    inventory_cap  INTEGER,
    funding_split  TEXT,                       -- JSON
    expiration     TEXT,
    terms          TEXT,
    margin_model   TEXT,                       -- JSON (binding margin contract)
    created_at     TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

CREATE TABLE IF NOT EXISTS campaign_briefs (
    id              TEXT PRIMARY KEY,
    campaign_id     TEXT NOT NULL REFERENCES campaigns(id),
    version         INTEGER NOT NULL,
    content_hash    TEXT NOT NULL,             -- freeze = hash-pinned snapshot (Council)
    content         TEXT NOT NULL,             -- JSON
    approval_evidence TEXT,                    -- JSON
    frozen_at       TEXT,
    created_at      TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

CREATE TABLE IF NOT EXISTS campaign_templates (
    id          TEXT PRIMARY KEY,
    name        TEXT NOT NULL,
    slug        TEXT NOT NULL UNIQUE,
    description TEXT,
    structure   TEXT,                          -- JSON
    version     INTEGER NOT NULL DEFAULT 1,
    status      TEXT NOT NULL DEFAULT 'draft'
                CHECK (status IN ('draft','active','retired')),
    created_at  TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

CREATE TABLE IF NOT EXISTS placements (
    id              TEXT PRIMARY KEY,
    source_code     TEXT NOT NULL,
    kind            TEXT NOT NULL CHECK (kind IN ('qr','nfc','shortlink','signage')),
    location_channel TEXT,
    campaign_id     TEXT REFERENCES campaigns(id),
    campaign_version INTEGER,
    active_interval TEXT,                      -- JSON
    url             TEXT NOT NULL,             -- resolvable, no private data
    created_at      TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

CREATE TABLE IF NOT EXISTS artifacts (
    id              TEXT PRIMARY KEY,
    type            TEXT NOT NULL CHECK (type IN ('passport','stamp','credential','badge','token','event_relic')),
    serial          TEXT NOT NULL,
    batch_id        TEXT,
    issued_ts       TEXT,
    status          TEXT NOT NULL DEFAULT 'allocated'
                    CHECK (status IN ('allocated','issued','void')),
    campaign_id     TEXT REFERENCES campaigns(id),
    participant_id  TEXT REFERENCES participants(id),
    secure_element_meta TEXT,                  -- nullable; never secrets on cheap tags
    created_at      TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

-- ---------------------------------------------------------------------------
-- Participants / Consents
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS participants (
    id              TEXT PRIMARY KEY,          -- pseudonymous opaque UUID
    contact_endpoint TEXT,                     -- JSON, encrypted, purpose-scoped
    source          TEXT,
    consent_status  TEXT NOT NULL DEFAULT 'none'
                    CHECK (consent_status IN ('none','opt_in','opt_out')),
    created_at      TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

CREATE TABLE IF NOT EXISTS consents (
    id              TEXT PRIMARY KEY,
    participant_id  TEXT NOT NULL REFERENCES participants(id),
    purpose         TEXT NOT NULL CHECK (purpose IN ('campaign_ops','service_comms','marketing','fraud_prevention')),
    channel         TEXT NOT NULL CHECK (channel IN ('sms','email','wallet','web')),
    notice_version  TEXT NOT NULL,
    timestamp       TEXT NOT NULL,
    method          TEXT,
    withdrawal_ts   TEXT,
    evidence        TEXT,                      -- JSON
    created_at      TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

-- ---------------------------------------------------------------------------
-- THE APPEND-ONLY EVENT LEDGER (FR-401..405) — system of record
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS events (
    id              TEXT PRIMARY KEY,          -- opaque event id
    kind            TEXT NOT NULL CHECK (kind IN
        ('scan','issue','stamp','claim','redemption','referral','attendance','exception')),
    actor_source    TEXT NOT NULL,
    campaign_id     TEXT REFERENCES campaigns(id),
    merchant_id     TEXT REFERENCES merchants(id),
    participant_id  TEXT REFERENCES participants(id),
    placement_id    TEXT REFERENCES placements(id),
    timestamp       TEXT NOT NULL,
    device_risk     TEXT,                      -- JSON (under fraud_prevention consent)
    idempotency_key TEXT NOT NULL UNIQUE,      -- FR-404: duplicate submission = no-op
    payload         TEXT,                      -- JSON
    created_at      TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);
-- No UPDATE/DELETE triggers: append-only is enforced in the ledger layer + a
-- trigger that rejects any UPDATE/DELETE (defense in depth).
CREATE TRIGGER IF NOT EXISTS events_no_update
    BEFORE UPDATE ON events
    BEGIN
        SELECT RAISE(ABORT, 'append-only: events may not be updated (use a compensating event)');
    END;
CREATE TRIGGER IF NOT EXISTS events_no_delete
    BEFORE DELETE ON events
    BEGIN
        SELECT RAISE(ABORT, 'append-only: events may not be deleted');
    END;

-- ---------------------------------------------------------------------------
-- Redemptions (projection of the ledger; state via K-REC-003 compensating events)
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS redemptions (
    id              TEXT PRIMARY KEY,
    offer_id        TEXT NOT NULL REFERENCES offers(id),
    merchant_id     TEXT NOT NULL REFERENCES merchants(id),
    participant_id  TEXT NOT NULL REFERENCES participants(id),
    event_id        TEXT NOT NULL REFERENCES events(id),
    pos_reference   TEXT,
    gross_sale_band TEXT,
    state           TEXT NOT NULL DEFAULT 'active'
                    CHECK (state IN ('active','void','refunded')),
    created_at      TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

-- ---------------------------------------------------------------------------
-- Communications / Labor / Costs / Reports / Audit / Exceptions / Kernels
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS communications (
    id              TEXT PRIMARY KEY,
    message         TEXT,
    audience_rule   TEXT,                      -- JSON
    channel         TEXT CHECK (channel IN ('sms','email','wallet','web')),
    consent_snapshot TEXT,                     -- JSON
    status          TEXT NOT NULL DEFAULT 'draft'
                    CHECK (status IN ('draft','queued','sent','delivered','failed','unsubscribed','complaint')),
    created_at      TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

CREATE TABLE IF NOT EXISTS labor_logs (
    id              TEXT PRIMARY KEY,
    campaign_id     TEXT REFERENCES campaigns(id),
    stage           TEXT,
    person_id       TEXT REFERENCES users(id),
    start_ts        TEXT,
    end_ts          TEXT,
    exception_type  TEXT,
    created_at      TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

CREATE TABLE IF NOT EXISTS costs (
    id              TEXT PRIMARY KEY,
    campaign_id     TEXT REFERENCES campaigns(id),
    category        TEXT NOT NULL CHECK (category IN ('production','media','labor','subsidies','vendor_fees','merchant_cofunding')),
    amount          REAL NOT NULL,
    description     TEXT,
    created_at      TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

CREATE TABLE IF NOT EXISTS reports (
    id              TEXT PRIMARY KEY,
    definition      TEXT NOT NULL,
    inputs_hash     TEXT NOT NULL,
    calculation_version INTEGER NOT NULL,
    generated_ts    TEXT NOT NULL,
    recipients      TEXT,                      -- JSON
    payload         TEXT,                      -- JSON
    status          TEXT NOT NULL DEFAULT 'draft'
                    CHECK (status IN ('draft','generated','frozen')),
    attribution_confidence TEXT CHECK (attribution_confidence IN ('high','medium','low')),
    baseline_ref    TEXT,                      -- Council: required for "incremental"/high claims
    created_at      TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

CREATE TABLE IF NOT EXISTS audit_log (
    id              TEXT PRIMARY KEY,
    actor           TEXT NOT NULL,
    action          TEXT NOT NULL,
    object          TEXT NOT NULL,
    before_after_hash TEXT,                    -- JSON
    timestamp       TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

CREATE TABLE IF NOT EXISTS exceptions (
    id              TEXT PRIMARY KEY,
    kernel_run_id   TEXT REFERENCES kernel_runs(id),
    severity        TEXT NOT NULL CHECK (severity IN ('info','anomaly','fraud_critical')),
    status          TEXT NOT NULL DEFAULT 'open'
                    CHECK (status IN ('open','ack','resolved')),
    operator_id     TEXT REFERENCES users(id),
    decision        TEXT,
    ts              TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

-- ---------------------------------------------------------------------------
-- Process kernels + runs (FR-701..708)
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS process_kernels (
    id              TEXT PRIMARY KEY,
    kernel_id       TEXT NOT NULL UNIQUE,      -- e.g. K-OPE-001
    name            TEXT NOT NULL,
    version         INTEGER NOT NULL DEFAULT 1,
    trigger         TEXT,                      -- JSON
    inputs_schema   TEXT,                      -- JSON
    rules_ref       TEXT,
    gate_flags      TEXT,                      -- JSON
    outputs_schema  TEXT,                      -- JSON
    verification_check TEXT,
    owner           TEXT,
    status          TEXT NOT NULL DEFAULT 'defined'
                    CHECK (status IN ('defined','reviewed','live','quarantined','retired')),
    created_at      TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
    updated_at      TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

CREATE TABLE IF NOT EXISTS kernel_runs (
    id              TEXT PRIMARY KEY,          -- run id
    kernel_id       TEXT REFERENCES process_kernels(kernel_id),
    trigger         TEXT,
    inputs_hash     TEXT,
    outputs_hash    TEXT,
    gate_outcomes   TEXT,                      -- JSON
    status          TEXT NOT NULL DEFAULT 'ready'
                    CHECK (status IN ('ready','running','passed','quarantined','blocked_on_gate','held','paused','rolled_back')),
    start_ts        TEXT,
    end_ts          TEXT,
    created_at      TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

-- ---------------------------------------------------------------------------
-- Indexes (tenant isolation + ledger read-back)
-- ---------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_events_idempotency ON events (idempotency_key);
CREATE INDEX IF NOT EXISTS idx_events_merchant ON events (merchant_id);
CREATE INDEX IF NOT EXISTS idx_events_campaign ON events (campaign_id);
CREATE INDEX IF NOT EXISTS idx_events_timestamp ON events (timestamp);
CREATE INDEX IF NOT EXISTS idx_redemptions_state ON redemptions (merchant_id, state);
CREATE INDEX IF NOT EXISTS idx_merchants_org ON merchants (organization_id);
