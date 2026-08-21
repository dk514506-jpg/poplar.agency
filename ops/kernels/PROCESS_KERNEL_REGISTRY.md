# Poplar.agency — Process Kernel Registry (v0.1)

**Status:** INTERNAL · DRAFT for Locus/Council review · 2026-08-20
**Authority:** Technical Requirements Baseline FR-701–708 (binding).
**Purpose:** Decompose every recurring Poplar campaign-operations business
process into discrete **process kernels** that a daemon-LLM-agent can
execute, with human gates where required. This is the technical spine of
"the agency experience."

---

## 0. What a kernel is (the contract)

Per FR-701, every kernel has these fields:

| Field | Meaning |
|-------|---------|
| `id` | stable kernel id (e.g. `K-INT-001`) |
| `name` | short imperative name |
| `trigger` | what starts a run (event / schedule / exception) |
| `inputs` | the data + references it consumes (schema-tagged) |
| `rules` | deterministic logic where possible; decision points named |
| `human_gates` | which steps BLOCK on a named approver (agent never self-approves) |
| `outputs` | artifacts/data written (schema-tagged) |
| `verification` | a pass/fail check; a failed run is quarantined, never silently retried |
| `escalation` | failure path + who sees the exception |
| `owner` | the role accountable for this kernel's definition |

**Execution rules (FR-702–708):**
- Deterministic parts run in **engine code**; judgment parts are **explicit model decisions**.
- Every run is **logged** (kernel id, run id, inputs hash, outputs hash, gate outcomes).
- Human-gate kernels **block** until the named approver acts.
- The daemon produces an **exceptions queue** — routine events flow without attention; only anomalies, gates, escalations surface to the operator.
- Every kernel has an **escape hatch**: pause, rollback (compensating event or config revert), or hand-off to a human without data loss.
- Kernel definitions are **versioned in private Git** and mirrored into the wiki.

**WHAT MAKES A KERNEL SAFE TO AUTO-EXECUTE (binding, per Council review):**
A kernel may run fully automatic (no human gate) ONLY if ALL THREE hold:
1. **Reversible or purely internal effect** — the action does not create a binding external commitment that cannot be undone.
2. **Deterministic run-time verification** — the kernel can verify its own output mechanically, not by judgment.
3. **Failure = quarantine + escalation, never retry** — a failed run is quarantined and surfaced; retry is a HUMAN decision, never silent.

Where any condition fails, the kernel is human-gated or auto-with-hold-on-signal (see below). This rule is the testable spine of "the daemon never self-approves."

**Binding posture (Q1/Q5/Q6):** this system is **agency-operations-centered** (Q1), **fixture/demo data only until merchant permission** (Q5), and **local-first with a self-hosted target** (Q6). These are load-bearing constraints on every kernel below.

---

## 1. Kernel inventory (by campaign lifecycle phase)

The campaign lifecycle (ops architecture §2) is: discover → design → approve →
launch → operate → reconcile → learn → archive. Each phase decomposes into kernels.

### Phase: Discover

| ID | Kernel | Trigger | Human gate | Notes |
|----|--------|---------|-----------|-------|
| K-DIS-001 | Merchant intake & capacity interview | lead created | operator review | capture capacity, slow periods, POS type, willingness to pay |
| K-DIS-002 | Slow-period & margin analysis | K-DIS-001 done | operator approves | compute candidate slow windows + margin guardrails from merchant data |
| K-DIS-003 | Campaign fit & economics draft | K-DIS-002 done | **merchant champion** | draft offer rules, reward ladder, budget; merchant signs economics |

### Phase: Design

| ID | Kernel | Trigger | Human gate | Notes |
|----|--------|---------|-----------|-------|
| K-DES-001 | Campaign brief assembly | K-DIS-003 done | operator | versioned brief from templates (FR-104) |
| K-DES-002 | Creative + copy generation | K-DES-001 done | **merchant + operator** | copy approval is a human gate; agent drafts, never releases |
| K-DES-003 | Service blueprint + staff runbook | K-DES-002 done | operator | one-page runbook; staff action < 30s target |
| K-DES-004 | Tracking + consent instrumentation plan | K-DES-003 done | operator + legal review | source IDs, QR placements, consent copy (FR-801, FR-502) |

### Phase: Approve

| ID | Kernel | Trigger | Human gate | Notes |
|----|--------|---------|-----------|-------|
| K-APP-001 | Economics & margin sign-off | K-DES-004 done | **merchant champion** | FR-304 margin re-check; approval evidence recorded |
| K-APP-002 | Data-sharing + support-boundary consent | K-APP-001 done | **merchant** | FR-202 permission state transition, evidence-tagged |
| K-APP-003 | Campaign approval & freeze | K-APP-002 done | **operator** | campaign status → approved; version frozen (hash-pinned brief snapshot) |
| K-APP-004 | Campaign amendment (mid-flight offer/budget change) | change request | **operator + merchant** | post-freeze change control — the classic merchant-dispute surface. Compensating/amendment events, never destructive edit. |

### Phase: Launch

| ID | Kernel | Trigger | Human gate | Notes |
|----|--------|---------|-----------|-------|
| K-LAU-001 | Placement & QR/source-code issuance | K-APP-003 done | operator | FR-801: every placement carries source id + campaign version |
| K-LAU-002 | Staff training & runbook distribution | K-LAU-001 done | operator | verify staff can execute target action |
| K-LAU-003 | Launch smoke test | K-LAU-002 done | operator | test every QR/code; rehearsal gate (Gate 1) |

### Phase: Operate (the daemon's home ground — exception-based)

| ID | Kernel | Trigger | Human gate | Notes |
|----|--------|---------|-----------|-------|
| K-OPE-001 | Event intake & validation | any scan/issue/stamp/claim/redemption event | none (auto) | idempotency, rate limits, duplicate detection (FR-302, FR-404) |
| K-OPE-002 | Anomaly detection & exceptions queue | K-OPE-001 events | **operator** for anomalies | velocity checks, fraud signals, copied-QR mitigation (FR-303) |
| K-OPE-003 | Daily exception review | daily schedule | **operator** | 10-min check; routine events pass silently |
| K-OPE-004 | Redemption server-validation | redemption event | none (auto) — **auto-with-hold-on-signal** | one-time semantics, expiration, history (FR-302). A validated redemption is a binding merchant obligation — a fraud/velocity flag (K-OPE-002) → `held`, resolved at daily review. Deferral is lossless; approval is not. |
| K-OPE-005 | Staff verification assist | staff verification action | staff (via UI) | one-tap/scan; manual fallback; exception path |
| K-OPE-006 | Consent withdrawal & suppression | withdrawal event | **none (AUTO — legally mandated immediacy)** | GDPR Art. 7(3) "without undue delay"; CCPA opt-out ≤15 days; withdrawal as easy as grant. Purely subtractive; verification = suppression confirmed in all outbound audiences; failure escalates. The one case where a human gate creates exposure, not safety. |
| K-OPE-007 | Stop-condition evaluation & campaign halt | stop condition hit OR anomaly escalation | **operator + merchant** | FR-704 stop decisions are human-gate kernels. Agent escalates (margin floor / staff burden / fraud / complaint rate / no-lift), never halts on its own. Compensating halt event; campaign → halt state. |

### Phase: Reconcile

| ID | Kernel | Trigger | Human gate | Notes |
|----|--------|---------|-----------|-------|
| K-REC-001 | Ledger reconciliation vs merchant records | campaign milestone / daily | **operator** | match issued/stamped/redeemed to POS/labor logs (I-7); daemon matches deterministically, human adjudicates exceptions |
| K-REC-002 | Missing/exception event resolution | K-REC-001 | **operator** | compensating events, never destructive edits (FR-403) |
| K-REC-003 | Redemption void/refund | void/refund request | **human** | owns `redemptions.state(active,void,refunded)` transitions — an orphaned financial state machine otherwise; void/refund is a binding financial action, never auto. |

### Phase: Learn

| ID | Kernel | Trigger | Human gate | Notes |
|----|--------|---------|-----------|-------|
| K-LEA-001 | Weekly pulse report | weekly schedule | operator (releases) | auto-*draft* by daemon; distribution human-released. distribution/participation/conversion/return signal (FR-602) |
| K-LEA-002 | End-of-campaign contribution-margin report | campaign end | **operator + merchant** | observed vs incremental with attribution confidence (FR-603) |
| K-LEA-003 | Learnings & next-version draft | K-LEA-002 | operator | feeds next campaign template |

### Phase: Archive

| ID | Kernel | Trigger | Human gate | Notes |
|----|--------|---------|-----------|-------|
| K-ARC-001 | Campaign archive & freeze | campaign end | operator | freeze results, retain only necessary records, record lessons |

---

## 2. Which kernels are daemon-executable vs human-gated (first vertical slice)

Per the baseline's open question ("which kernels are daemon-executable vs
human-gated in the first vertical slice; Dallas approves"), this is the
proposal for review:

**Auto (daemon executes, no human gate):**
- K-OPE-001 Event intake & validation
- K-OPE-004 Redemption server-validation — **auto-with-hold-on-signal**: a fraud/velocity flag → `held`, resolved at daily review (approving past a flag commits merchant money; deferral is lossless)
- K-OPE-002 Anomaly detection (produces exceptions; does not act on them)
- K-OPE-006 **Consent withdrawal & suppression** — AUTO (legally mandated immediacy: GDPR Art. 7(3), CCPA opt-out ≤15 days; withdrawal as easy as grant)
- K-LEA-001 Weekly pulse report — auto-*draft* only (see draft-only; operator releases)

**Auto-with-escalation (daemon executes; surfaces to operator on anomaly):**
- K-OPE-003 Daily exception review — auto-runs the sweep; SAFE only with explicit per-exception ack (logged), aging escalation (unacked 24h → page), severity-tiered SLA (fraud-critical signals page immediately, never at daily cadence). Ban tacit-consent timeouts ("unacted = acknowledged" is silent self-approval).

**Human-gated (agent drafts/proposes, named approver decides — agent never self-approves):**
- K-DIS-003, K-APP-001, K-APP-002, K-APP-003 (campaign economics/consent/approval) [K-DES-002 copy approval is the draft-only human release, not a separate gate]
- K-APP-004 (campaign amendment — post-freeze change control, classic merchant-dispute surface)
- K-LEA-002 (incremental claims require human judgment + merchant sign-off)
- K-REC-001/002 (reconciliation requires merchant-record truth, human adjudication)
- K-REC-003 (redemption void/refund — binding financial action, never auto)
- K-OPE-007 (stop-condition evaluation & campaign halt — FR-704 stop is a human gate)
- K-LAU-002/003 (staff training + launch smoke are physical, human actions)

**Draft-only (agent produces draft, human releases):**
- K-DES-001, K-DES-002 (briefs, creative, copy) — K-DES-002 is draft-only + human release (single category; resolves the earlier duplication)
- K-DES-003, K-DES-004 (runbook, instrumentation plan)
- K-LEA-001 (auto-drafts the weekly pulse; operator releases)

---

## 3. Kernel run lifecycle (state machine)

```
READY → RUNNING → PASSED (logged, verified)
              → QUARANTINED (verification failed; surfaced to exceptions queue)
              → BLOCKED_ON_GATE (human-gate waiting on named approver)
              → HELD (auto-with-hold-on-signal: fraud/velocity flag; resolved at daily review)
              → PAUSED (FR-708 escape hatch: operator pauses mid-run; resumable without data loss)
              → ROLLED_BACK (compensating event or config revert)
```

- A kernel that fails its verification check is **quarantined and surfaced** — never silently retried into success (baseline Gate/Kernel-specific acceptance). Retry is a HUMAN decision.
- A human-gated kernel sits in `BLOCKED_ON_GATE` until the approver acts; the daemon does not time it out into self-approval.
- `HELD` is the auto-with-hold-on-signal state: the daemon completes nothing that is a binding merchant obligation past a fraud/velocity flag; it defers (lossless) to human review.
- `PAUSED` is the FR-708 pause escape hatch: a run can be paused mid-flight and resumed without data loss, or handed to a human.

---

## 4. Kernel registry (FR-707)

The registry is the durable list of every defined kernel with:
`owner`, `trigger`, `status` (defined / reviewed / live / quarantined / retired), and `last_run_verification`.

Initial registry state: all kernels in this doc are **defined** (pending Locus/Council review + Dallas approval). `last_run_verification` is empty until the fixture slice runs them.

---

## 5. Open items / for review

- **For Dallas approval (the binding decisions):**
  - Confirm the auto vs human-gate split above (revised per Council review: K-OPE-004 auto-with-hold-on-signal, K-OPE-006 auto, K-OPE-003 auto-with-escalation-with-ack, K-APP-004 + K-REC-003 + K-OPE-007 human-gated).
  - Confirm the first-slice kernel set: the full lifecycle (per G1 "operate one campaign end-to-end").
  - Confirm the consents purpose enum gains `fraud_prevention` (Council amendment — events.device_risk needs a covering purpose under GDPR purpose limitation).
  - Confirm kernel input/output schema exact fields (see Domain Model & Data Contract).
- Which campaign templates (FR-104) need a distinct kernel set (proposal: none — templates parameterize the same kernels).
- K-OPE-003 daily review SLA specifics (aging escalation + severity-tiered paging) to be finalized at build.
- Kernel registry count is now **28** (verified): original 24 + K-OPE-006 (consent withdrawal), K-OPE-007 (stop/halt), K-APP-004 (campaign amendment), K-REC-003 (redemption void/refund).

---

*This registry turns "the agency experience" from a narrative into a runnable, auditable, exception-based operating system — the daemon-LLM-agent executing routine kernels, humans holding every binding gate.*
