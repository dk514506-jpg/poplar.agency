# Poplar.agency — Domain Model & Data Contract (v0.1)

**Status:** INTERNAL · DRAFT for Locus/Council review · 2026-08-20
**Authority:** Technical Requirements Baseline §7 (data contract), §13 (next artifact).
**Purpose:** The concrete schema-level sheet spec for every core entity, the
event ledger, consent, and the kernel registry. This is what a reviewer can
trace a claim through, and what a builder implements.

---

## 0. Conventions

- **Opaque UUIDs** for all primary keys (no PII in IDs).
- **Tenant isolation** at every query boundary (FR-203).
- **Append-only events**; corrections are **compensating events** (FR-403).
- **Idempotency keys** on every externally-triggered event (FR-404).
- Fixture/demo data only in v1 (Q5). No live customer/contact/merchant data.

## 1. Core entity schemas (baseline §7, made concrete)

### organizations
`id` uuid PK · `legal_name` text · `timezone` text · `status` enum(draft,active,inactive) · `created_at` ts · `updated_at` ts

### users
`id` uuid PK · `organization_id` fk → organizations · `merchant_id` fk → merchants (nullable — Council amendment: a merchant_champion with only organization_id could see every merchant; schema-level tenant hole) · `email` text · `role` enum(operator,admin,merchant_champion,merchant_staff,auditor) · `mfa_enabled` bool · `status` enum(active,disabled) · `created_at` ts

### merchants
`id` uuid PK · `organization_id` fk → organizations · `name` text · `address` text · `hours` jsonb · `capacity_notes` text · `pos_system` text · `permission_state` enum(lead,permissioned_example,authorized) · `contact` jsonb(encrypted) · `created_at` ts

### campaigns
`id` uuid PK · `name` text · `neighborhood` text · `objective` text · `hypothesis` text · `baseline_control` jsonb · `status` enum(discover,design,approve,launch,operate,reconcile,learn,archive) · `version` int · `owner_id` fk → users · `budget` jsonb · `start_date` date · `end_date` date · `created_at` ts · `updated_at` ts

### campaign_merchants
`id` uuid PK · `campaign_id` fk → campaigns · `merchant_id` fk → merchants · `role` text · `offer_id` fk → offers · `capacity_window` jsonb · `approved_copy` text · `economics` jsonb · `approval_state` enum(pending,approved,declined) · `created_at` ts

### offers
`id` uuid PK · `campaign_id` fk → campaigns · `merchant_id` fk → merchants · `title` text · `validity_window` jsonb · `min_spend` numeric · `exclusions` jsonb · `inventory_cap` int · `funding_split` jsonb · `expiration` ts · `terms` text · `margin_model` jsonb · `created_at` ts

### artifacts (physical collectibles / credentials)
`id` uuid PK · `type` enum(passport,stamp,credential,badge,token,event_relic) · `serial` text · `batch_id` text · `issued_ts` ts · `status` enum(allocated,issued,void) · `campaign_id` fk → campaigns · `participant_id` fk → participants (nullable) · `secure_element_meta` jsonb (nullable; never secrets on cheap tags) · `created_at` ts

### placements (QR / NFC / source-code)
`id` uuid PK · `source_code` text · `kind` enum(qr,nfc,shortlink,signage) · `location_channel` text · `campaign_id` fk → campaigns · `campaign_version` int · `active_interval` jsonb · `url` text (resolvable, no private data) · `created_at` ts

### participants
`id` uuid PK (pseudonymous) · `contact_endpoint` jsonb (nullable, encrypted, purpose-scoped) · `source` text · `consent_status` enum(none,opt_in,opt_out) · `created_at` ts

### consents
`id` uuid PK · `participant_id` fk → participants · `purpose` enum(campaign_ops,service_comms,marketing,**fraud_prevention**) · `channel` enum(sms,email,wallet,web) · `notice_version` text · `timestamp` ts · `method` text · `withdrawal_ts` ts (nullable) · `evidence` jsonb · `created_at` ts
> Council amendment: `fraud_prevention` purpose added — `events.device_risk` is collected under purposes that must cover it (GDPR purpose limitation). Per-purpose withdrawal rows; processor disclosure rides in notice_version + evidence.

### campaign_briefs
`id` uuid PK · `campaign_id` fk → campaigns · `version` int · `content_hash` text · `content` jsonb · `approval_evidence` jsonb · `frozen_at` ts · `created_at` ts
> Council amendment: a bare `version int` cannot prove what was frozen; freeze = hash-pinned snapshot.

### campaign_templates
`id` uuid PK · `name` text · `slug` text UNIQUE · `description` text · `structure` jsonb · `version` int · `status` enum(draft,active,retired) · `created_at` ts
> Council amendment: FR-104 names campaign templates (slow-period pass, neighborhood route, event relic, founding cohort, cross-business challenge) but defines no entity; this gives them a home.

### events (THE append-only ledger — FR-401)
`id` uuid PK (opaque event id) · `kind` enum(scan,issue,stamp,claim,redemption,referral,attendance,exception) · `actor_source` text · `campaign_id` fk → campaigns · `merchant_id` fk → merchants · `participant_id` fk → participants (nullable) · `placement_id` fk → placements (nullable) · `timestamp` ts · `device_risk` jsonb · `idempotency_key` text UNIQUE · `payload` jsonb · `created_at` ts
> Append-only. A correction = a new `exception`/compensating event, never an UPDATE/DELETE.

### redemptions
`id` uuid PK · `offer_id` fk → offers · `merchant_id` fk → merchants · `participant_id` fk → participants · `event_id` fk → events · `pos_reference` text · `gross_sale_band` text (nullable) · `state` enum(active,void,refunded) · `created_at` ts

### communications
`id` uuid PK · `message` text · `audience_rule` jsonb · `channel` enum(sms,email,wallet,web) · `consent_snapshot` jsonb · `status` enum(draft,queued,sent,delivered,failed,unsubscribed,complaint) · `created_at` ts

### labor_logs
`id` uuid PK · `campaign_id` fk → campaigns · `stage` text · `person_id` fk → users · `start_ts` ts · `end_ts` ts · `exception_type` text (nullable) · `created_at` ts
> Used to price Poplar operations (contribution-margin honesty).

### costs
`id` uuid PK · `campaign_id` fk → campaigns · `category` enum(production,media,labor,subsidies,vendor_fees,merchant_cofunding) · `amount` numeric · `description` text · `created_at` ts

### reports
`id` uuid PK · `definition` text · `inputs_hash` text · `calculation_version` int · `generated_ts` ts · `recipients` jsonb · `payload` jsonb · `status` enum(draft,generated,frozen) · `attribution_confidence` enum(high,medium,low) (nullable) · `baseline_ref` text (nullable) · `created_at` ts
> Immutable; report versioning (FR-604). **No-overclaim enforcement (Council):** any report claiming "incremental" or attribution_confidence=high MUST carry a `baseline_ref` pointing at a hash-pinned baseline_control; otherwise K-LEA-002's verification fails it.

### audit_log
`id` uuid PK · `actor` text · `action` text · `object` text · `before_after_hash` jsonb · `timestamp` ts · `created_at` ts

### exceptions
`id` uuid PK · `kernel_run_id` fk → kernel_runs · `severity` enum(info,anomaly,fraud_critical) · `status` enum(open,ack,resolved) · `operator_id` fk → users (nullable) · `decision` text (nullable) · `ts` ts · `created_at` ts
> Council amendment: the audit spine of "the daemon never self-approves" — every surfaced exception gets a row here with open→ack→resolved + operator + decision. K-OPE-003 ack, aging escalation (unacked 24h → page), and severity-tiered SLA all key off this table.

## 2. Kernel schema (FR-701, concrete)

### process_kernels
`id` uuid PK · `kernel_id` text UNIQUE (e.g. K-OPE-001) · `name` text · `version` int · `trigger` jsonb · `inputs_schema` jsonb · `rules_ref` text · `gate_flags` jsonb · `outputs_schema` jsonb · `verification_check` text · `owner` text · `status` enum(defined,reviewed,live,quarantined,retired) · `created_at` ts · `updated_at` ts

### kernel_runs
`id` uuid PK (run id) · `kernel_id` fk → process_kernels · `trigger` text · `inputs_hash` text · `outputs_hash` text · `gate_outcomes` jsonb · `status` enum(ready,running,passed,quarantined,blocked_on_gate,rolled_back) · `start_ts` ts · `end_ts` ts · `created_at` ts
> Every run logged for audit + reconciliation (FR-703).

## 3. Cross-cutting rules

- **Tenant isolation:** every query joins on `merchant_id`/`organization_id`; a merchant's console sees only its rows (tested, FR-203).
- **Consent separation:** `campaign_ops` consent does NOT imply `marketing`; no silent purpose-bleed (FR-503). Withdrawal/suppression immediate + testable (FR-504).
- **No public PII:** public records limited to business/offer/event/route + opt-in achievements (FR-505).
- **Idempotency:** re-submitting an external event with the same idempotency key is a no-op (FR-404).
- **Secrets:** never in tags, QR payloads, source control, or reports (NFR-04, NFR-05). Secret store for credentials.

## 4. For review

1. Confirm `events` is the single system-of-record spine (recommend yes — the customer-facing passport is a projection of it, never a separate source).
2. Confirm the `consents` purpose enum is sufficient (campaign_ops / service_comms / marketing).
3. Confirm `reports` immutability model (calculation_version + inputs_hash) matches FR-604.
4. Whether `redemptions.gross_sale_band` is enough for v1 contribution-margin (recommend yes; exact POS amount deferred to reconciliation).

---

*This is the sheet spec a reviewer can trace a claim through and a builder can implement directly. It is the concrete form of "the agency experience."*
