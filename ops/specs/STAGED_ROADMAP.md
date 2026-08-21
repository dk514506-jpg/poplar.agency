# Poplar.agency — Staged Implementation Roadmap (v0.1)

**Status:** INTERNAL · DRAFT for review · 2026-08-20
**Authority:** Technical Requirements Baseline §10 (phases) + Q1 (vertical slice, agency-ops-centered).
**Purpose:** The ordered build that turns the bore-down specs into a runnable fixture slice.

---

## Stage 0 — Spec ratification (this pass)
- Locus + Council review the bore-down suite (kernel registry, boundary, domain, gates, classification).
- Dallas approves: auto vs human-gate split, first-slice kernel set, consents enum, report-immutability.
- **Exit:** suite APPROVED; decisions recorded in the Poplar decision log.

## Stage 1 — Fixture vertical slice (one campaign end-to-end, G1)
- **Schema + ledger:** implement the domain-model tables + append-only event ledger + idempotency (fixture data).
- **Kernel engine:** implement the kernel runner (READY→…→QUARANTINED/PAUSED/HELD/BLOCKED_ON_GATE) over the first-slice kernel set; escape-hatch/rollback tested here (kernel-engine property).
- **Surfaces:** admin console (I-4), staff verification (I-2), customer QR/short-link web (I-1), export (I-6).
- **Fixtures:** generate demo data from the Lakeview/N Broadway market data (labeled DEMO/NOT LIVE; **names fictionalized + metrics perturbed** per Council — "labeled DEMO" is not anonymization).
- **Gate 3 mechanical checks moved here** (Council): secret scan, dependency audit, tenant isolation, access control — run in CI during the fixture build, not deferred.
- **Exit:** Gate 0 + Gate 2 (data correctness) pass on fixtures; the full lifecycle K-DIS→K-ARC runs end-to-end.

## Stage 2 — Internal rehearsal
- Three end-to-end rehearsals on real phones (slow connection included), staff ≤30s (pre-stated protocol, median ≥3 trials), QR fallback tested.
- Kernel runs logged; exceptions queue exercised (ack + aging escalation).
- **Attribution + baseline methodology verified on fixtures** (Council); **stop/revise/scale thresholds pre-registered at Stage 2 EXIT** (before live data — a threshold registered mid-pilot is a post-hoc magnet).
- **Consent package + legal review completes at Stage 2 exit** (Council — not "with" the pilot).
- **Exit:** Gate 1 (experience rehearsal) + Gate 3 (security/privacy on fixtures) pass.

## Stage 3 — Live pilot (only after merchant permission)
- One campaign per authorized merchant (Lakeview Loop). Daily exception review; weekly pulse.
- Reconciliation vs POS/labor exports (I-7). Contribution-margin decision at end.
- **Exit:** Gate 4 + Gate 5 (post-launch); written stop/revise/scale decision against pre-registered thresholds.

## Stage 4 — Production primitives (only after validated pilot)
- Auth/tenant hardening, retention jobs, backups, report versioning, optional Wallet pass.
- AT/public records only if portability/discovery is a validated need.

## Stage 5 — Reusable agency system
- Merchant console (I-3), campaign automation, standardized onboarding/pricing, reusable templates.

---

## Gate-to-stage mapping

| Stage | Gates exercised |
|-------|-----------------|
| 0 spec | — (review + approvals) |
| 1 fixture | Gate 0, Gate 2 |
| 2 rehearsal | Gate 1, Gate 3 |
| 3 pilot | Gate 4, Gate 5 |
| 4–5 production | hardening + scale |

## For review
1. Confirm the first-slice kernel set covers the full lifecycle (recommend: yes, per G1 "operate one campaign end-to-end").
2. Confirm fixture-data-only through Stage 2 (recommend: yes; live data only at Stage 3 with merchant permission + consent package).
