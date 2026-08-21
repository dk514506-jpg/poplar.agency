# Poplar.agency — Verification & Release Gates (v0.1)

**Status:** INTERNAL · DRAFT for Locus/Council review · 2026-08-20
**Authority:** Technical Requirements Baseline §9 (gates 0–5) + kernel-specific acceptance.
**Purpose:** Make every gate a concrete, testable acceptance criterion a
reviewer can verify on disk — not prose. This is the quality spine of "the
agency experience."

---

## 0. Principle

A gate is passed only when its checks **execute** and pass — static reading is
not evidence. Every gate has: a named check, a command/artefact that proves it,
and a pass/fail rule. This mirrors the engineering discipline used across the
owner's projects (testable, evidence-gated, honest negatives).

---

## Gate 0 — Economics & consent

| Check | Evidence | Pass rule |
|-------|----------|-----------|
| Campaign brief approved | signed brief (campaign_briefs.approval_evidence; campaigns.status=approved) | present + signed |
| Offer margin model | offers.margin_model populated for every merchant | all merchants have a margin model |
| Baseline/control method | campaigns.baseline_control defined + **hash-pinned** | explicit; "matches design" = hash equality (Council) |
| Data inventory | consent/retention inventory artifact | complete; no live data |
| Consent copy | consent notice text (versioned) | approved by operator + (where required) legal |
| Retention decision | retention schedule documented | stated before any live data (N/A fixture) |
| Merchant sign-off | campaign_merchants.economics approval evidence | per-merchant recorded |

## Gate 1 — Experience rehearsal

| Check | Evidence | Pass rule |
|-------|----------|-----------|
| 3 end-to-end rehearsals | rehearsal log (K-LAU-003), real phones, slow connection included | 3 distinct, logged |
| Staff routine action in target | rehearsal timing, **pre-stated protocol** (device, N trials) | ≤ 30s per eligible event, median over ≥3 trials (Council: three cherry-picked passes fail trivially) |
| QR fallback works | every NFC flow has a working QR fallback (FR-802) | all tested, no broken fallback |

## Gate 2 — Data correctness

| Check | Evidence | Pass rule |
|-------|----------|-----------|
| Idempotency | duplicate external event with same idempotency key | no-op (test) |
| Tenant isolation | cross-merchant query returns nothing | test passes (deduped here from Gate 3) |
| Access control | least-privilege matrix enforced (incl. users.merchant_id scoping) | test passes |
| Timezone/date-boundary | events near midnight/zone edge | correct attribution |
| Duplicate scan/redemption | one-time semantics enforced | second attempt rejected |
| Refund/void | redemptions.state transitions via K-REC-003 | correct + ledgered |
| Audit-log assertions | audit_log + exceptions table complete | all actions traced |
| Report fixtures | report version reproducible | fixture regenerates identical |
| **Kernel quarantine** | failed verification → kernel_runs.status=quarantined, surfaced to exceptions queue, zero silent retries; BLOCKED_ON_GATE never auto-approved | CI test passes (Council/Locus) |

## Gate 3 — Security/privacy

| Check | Evidence | Pass rule |
|-------|----------|-----------|
| Secret scan | repo scan (no secrets in code/config) | zero findings |
| Dependency audit | pinned deps audited | no known-vuln in v1 set |
| MFA/admin review | admin MFA enforced + reviewed | enabled |
| Encrypted transport | TLS at rest/in transit where supported | verified |
| Backup restore | backup+restore test | restore succeeds |
| Deletion/suppression | consent withdrawal (K-OPE-006) + data suppression testable | immediate + tested |
| Abuse/rate-limit | velocity + rate limits enforced | test passes |
| Copied-QR threat model | documented + server-validation | validation in place |

## Gate 4 — Operational readiness

| Check | Evidence | Pass rule |
|-------|----------|-----------|
| Runbook | printed/shared one-page runbook | present + current |
| Escalation contacts | named + confirmed | confirmed |
| Support hours | stated | stated |
| Vendor status | dependency status checked | verified |
| Monitoring | error/anomaly monitoring active | active |
| Rollback/kill switch | tested | test passes |
| Backup staff | trained | trained + named |

## Gate 5 — Launch & post-launch

| Check | Evidence | Pass rule |
|-------|----------|-----------|
| Tagged/versioned release | git tag + version | present |
| First-day smoke check | smoke log (K-LAU-003) | logged + pass |
| Daily anomaly review | exceptions table: zero exceptions unacked >24h | all acked <24h (Council: mechanical evidence) |
| End report reproducible | report regenerates from frozen inputs (FR-604) | identical |

## Kernel-specific acceptance (binding, from baseline)

| Invariant | Check | Evidence | Pass rule |
|-----------|-------|----------|-----------|
| Quarantine on failed verification | failed run | kernel_runs.status=quarantined; surfaced to exceptions queue | CI test: status set, exception row created |
| No silent retry into success | failed run + retry | retry only on explicit human decision; each retry logged | no auto-retry; retry is a HUMAN decision |
| No auto-approval of BLOCKED_ON_GATE | human-gated run | remains BLOCKED_ON_GATE until approver acts | daemon never times out into self-approval |
| No auto-halt on stop condition | stop condition hit | K-OPE-007 escalates, does not halt | campaign halt requires operator + merchant |

A kernel run that **fails verification is quarantined and surfaced** — never
silently retried into success (this is the anti-fabrication spine: the daemon
cannot paper over a failed reconciliation or a failed verification by re-running).
A human-gated kernel in `BLOCKED_ON_GATE` is **not** auto-approved by the
daemon, no matter how many retries.

## The anti-overclaim rule (the soul of Gate 5 / K-LEA-002)

A visit is **incremental** only with a baseline period, matched comparison, or
controlled offer (FR-603). Attribution confidence is labeled **high/medium/low**.
A report that calls a QR scan "incremental" without a baseline is a **gate failure**,
not a finding — mirroring the "a confident inference is never a lived fact"
discipline from the broader work.

---

## For review

1. Confirm the gates execute as **CI-checkable + human-verified** (recommend: mechanical checks run in CI; human gates recorded as evidence, not assumed).
2. Confirm kernel quarantine-on-failure is a hard invariant (recommend: yes — no silent retry into success).
3. Confirm Gate 5's incremental-attribution rule is binding (recommend: yes — it is the economic-integrity claim).

---

*The gates turn "we ran a campaign" into "we can prove we ran it correctly, privately, and without overclaiming."*
