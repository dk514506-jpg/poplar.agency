# Poplar.agency — Decisions Log

**Status:** ACTIVE / authoritative decision record · 2026-08-20
**Authority:** Build Clarification Q (decisions log); Technical Requirements Baseline §12 (traceability).
**Purpose:** Record every binding decision for Poplar's technical stack. Per the baseline: "Any proposed change to a DECIDED item requires a decision-log entry, not a silent edit."

---

## Evidence labels
- `DECIDED` — explicitly approved by Dallas (or adopted-on-assumption per his direction).
- `RECOMMENDED` — proposed default awaiting approval.
- `TBD` — unresolved; the condition that decides it stated.
- `ASSUMED` — temporary working assumption.
- `VERIFIED` — supported by a source/directly inspected artifact.
- `INFERENCE` — planning implication, not a stated fact.

---

## Decisions (from the Technical Requirements Baseline clarification, 2026-08-15)

| ID | Decision | Source | Status |
|----|----------|--------|--------|
| D-001 | First engineered product = **combined vertical slice, agency operations as the center of gravity** | Q1 | DECIDED |
| D-002 | First validated behaviors = **slow-period visit generation, repeat visit, referral** (interwoven) | Q2 | DECIDED |
| D-003 | Commercial model = **managed service for merchant; software enables Poplar's operations** | Q3 | DECIDED |
| D-004 | Initial system users = **phased: operator → merchant staff → customers** | Q4 | DECIDED |
| D-005 | Data = **fixture/demo only** until merchant permission; generated from market data | Q5 | DECIDED |
| D-006 | Deployment = **local-first, self-hosted target**; vendor-neutral where possible | Q6 | DECIDED |
| D-007 | Tradeoff priority = operational simplicity → reversibility/export → pilot speed → privacy/security → extensibility → nominal cost | Q7 | DECIDED |
| D-008 | Public/private artifact policy = **adopted as written** (3 tiers) | Q8 | DECIDED |
| D-009 | Document hierarchy = **adopted as written** (Decisions → Baseline → Ops Arch → Plan → Research → Kanban → GitHub) | Q9 | DECIDED |
| D-010 | Next-artifact set = all listed; **Technical Requirements Baseline authoritative** | Q10 | DECIDED |
| D-011 | Constraint = business processes **simplify to kernels executable by a daemon-LLM-agent** | constraint | DECIDED |
| D-012 | Private-Git boundary arrangement = **adopted as proposed** | strategic Q | DECIDED |

---

## Bore-down decisions (2026-08-20, adopted on assumption per Dallas's direction to proceed)

The four binding calls flagged for sign-off in the kernel-registry open items, adopted per the recommended default:

| ID | Decision | Recommendation adopted | Status |
|----|----------|------------------------|--------|
| D-020 | **Auto-vs-human-gate split** | K-OPE-004 auto-with-hold-on-signal; K-OPE-006 auto (legally-mandated consent withdrawal); K-OPE-003 auto-with-escalation-with-ack (explicit ack, aging escalation, severity-tiered SLA, no tacit-consent timeouts); K-APP-004, K-REC-003, K-OPE-007 human-gated | DECIDED (assumed 2026-08-20) |
| D-021 | **First-slice kernel set** | The full 28-kernel lifecycle (per G1: operate one campaign end-to-end) | DECIDED (assumed 2026-08-20) |
| D-022 | **`consents.purpose` gains `fraud_prevention`** | Council amendment adopted — events.device_risk needs a covering purpose under GDPR purpose limitation | DECIDED (assumed 2026-08-20) |
| D-023 | **Merchant-gate v1 mechanism** | Operator-mediated evidence capture (option a) — lowest cost, keeps I-3 console as phase 2 | DECIDED (assumed 2026-08-20) |

> NOTE: these four were adopted on the basis of Dallas's instruction to "proceed with assumptions." They should be confirmed as final on the next review, per the baseline's rule that a change to a DECIDED item needs a decision-log entry. If any differs from Dallas's intent, record a correction here.

---

## Open decisions (from baseline §11 + project plan §13, still TBD)

| Item | Condition that decides it |
|------|--------------------------|
| Exact stack choices (SQLite vs Postgres, NocoDB vs custom UI, static vs server-rendered) | evaluate against the baseline, not before it |
| Whether "Lakeview Loop" remains the campaign name | merchant/neighborhood confirmation |
| Which campaign templates (FR-104) need a distinct kernel set | proposal: none — templates parameterize the same kernels (TBD) |
| K-OPE-003 daily-review SLA specifics (aging escalation + severity paging) | finalize at build |
| Geographic relationship among the four businesses | field confirmation |
| Which customer behavior is primary | marketing decision |
| Desired Poplar visual identity | taste decision |
| First prototype surface | Phase-A/B evidence |

---

## Revision history
- 2026-08-15 — baseline decisions D-001..D-012 recorded (from clarified questionnaire).
- 2026-08-20 — bore-down decisions D-020..D-023 recorded (adopted on assumption); open items carried.
