# Poplar.agency — System Boundary & Context (v0.1)

**Status:** INTERNAL · DRAFT for Locus/Council review · 2026-08-20
**Authority:** Technical Requirements Baseline §8 (interfaces), §13 (next artifact).
**Purpose:** Define the system's boundaries — what is IN the agency operations
system, what is OUT, and every interface to external actors/systems. This is
the container that gives "the agency experience" its edges.

---

## 1. The system in one line

Poplar's technical system is the **agency campaign-operations system of record
and automation**: the private system that lets Poplar (one operator + daemon-LLM
agents) run one or more neighborhood campaigns end-to-end — intake → design →
approve → launch → operate → reconcile → learn — on fixture/demo data, local-first,
with every event ledgered and every binding decision human-gated.

It is **not** the customer-facing loyalty product per se (that's a surface), and
**not** a general CRM/POS/payment system.

## 2. Inside the boundary (Poplar owns)

- Campaign registry + versioned briefs (FR-101..105)
- Merchant + tenant records (FR-201..203)
- Offer/redemption rules engine (FR-301..304)
- The interaction event ledger (FR-401..405) — append-only system of record
- Participant + consent records (FR-501..505)
- Reporting/measurement (FR-601..604)
- Process-kernel engine + daemon-LLM-agent execution + exceptions queue (FR-701..708)
- Placement/hardware inventory (FR-801..804)
- Admin console + staff verification surface + export + reconciliation interfaces

## 3. Outside the boundary (Poplar does NOT own / explicitly out)

- Merchant POS systems & transaction truth (merchant owns; Poplar reconciles via export)
- Payment processing (third-party/vendor)
- Email/SMS delivery infrastructure (vendor, post-consent)
- Wallet pass signing infrastructure (vendor)
- Public social distribution as a system of record (platforms are reach surfaces, never the ledger)
- Customer's food/service complaints (merchant)
- Alcohol/age/tax compliance (merchant)

## 4. External actors

| Actor | Boundary | Trust |
|-------|----------|-------|
| Poplar operator (Dallas, then staff) | Full admin | highest — MFA, least-privilege reviewed |
| Merchant champion / backup | Own merchant's records only (phase 2) | tenant-scoped |
| Merchant staff | Verification surface only | least-privilege, no cross-merchant |
| Customer/participant | QR/short-link interaction, passport/progress, consent (+ one-tap withdrawal) | pseudonymous |
| Daemon LLM agent | Executes kernels; drafts; never binding commitments | **engine-bounded, fully logged, non-self-approving** |
| System auditor | Read-only full | reconciliation/verification |

> **Merchant-gate resolution (Council):** K-APP-001/002/003 are human-gated on the merchant champion in v1, but the I-3 console is phase 2. The v1 mechanism must be one of: (a) operator-mediated evidence capture (operator records the merchant's signed approval + evidence), or (b) a minimal non-console champion surface. Without stating which, "merchant signs economics" is unbuildable. Recommendation: (a) operator-mediated evidence capture for v1 — lowest cost, keeps I-3 as the phase-2 console.

## 5. Interfaces (from baseline §8, expanded)

| ID | Interface | Direction | Notes |
|----|-----------|-----------|-------|
| I-1 | Customer surface | web → customer | mobile-first, low-bandwidth, QR/short-link, no app |
| I-2 | Staff verification | staff → system | one-tap/scan; runbook; manual fallback |
| I-3 | Merchant console (phase 2) | merchant → system | own records, approvals, reports; tenant-scoped |
| I-4 | Poplar admin console | operator → system | campaigns, merchants, ledger, kernels, exceptions, reports |
| I-5 | Kernel engine/daemon | system ↔ engine | declarative kernels, run logs, gate queue, escalation |
| I-6 | Export | system → CSV/JSON | every ledger + config; documented schema |
| I-7 | Reconciliation | system ↔ POS/labor exports | match issued/stamped/redeemed; before direct integration |

## 6. Trust boundaries & data flow

```
CUSTOMER ──QR/NFC──▶ I-1 web ──▶ event ledger ──▶ report
STAFF    ──I-2─────▶ verification ──▶ event ledger
MERCHANT ──I-3─────▶ tenant-scoped records/approvals
OPERATOR ──I-4─────▶ admin console ──▶ kernels/ledger/reports
DAEMON   ──I-5─────▶ executes kernels ──▶ exceptions queue ──▶ operator
              (human-gated kernels BLOCK on approver)
POS      ──I-7─────▶ reconciliation (export, before direct integration)
```

- **Append-only ledger** is the single source of truth for measurement.
- Public pages / social platforms are **reach surfaces only** — never the system
  of record for private data (FR-405).
- **Tenant isolation** at every query boundary (FR-203) — tested, not assumed.

## 7. Explicit non-goals (boundary statement, from baseline §3.2)

No native app, no custom blockchain/payment rail/crypto requirement, no NFC
payment terminals, no automated POS integration, no custom PDS/App View/relay,
no full loyalty-points economy, no live customer data in v1 (fixture only), no
managed-cloud dependency, no public social as system of record.

## 8. What this spec decides (for review)

1. The boundary is **agency-operations-centered** (Q1): customer surface is a
   spoke, not the hub. Recommend this stays the v1 container.
2. The daemon executes **routine kernels** and **drafts**; every binding
   external commitment is human-gated (FR-704).
3. Public/social are **distribution surfaces**, never ledger — this protects
   the private-consent posture (FR-505).

---

*The boundary is deliberately narrow: Poplar runs campaigns; merchants run their
business; the system records every interaction and gates every commitment.*
