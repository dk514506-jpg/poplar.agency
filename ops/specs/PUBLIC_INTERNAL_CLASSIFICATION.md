# Poplar.agency — Public/Internal Artifact Classification (v0.1)

**Status:** INTERNAL policy · DRAFT for review · 2026-08-20
**Authority:** Build Clarification Q8 (adopted as written) + baseline §13.
**Purpose:** A single working rule for what may appear on the public GitHub
repo vs what stays internal/private. Prevents trade-secret or private-merchant
leakage while still presenting a credible public face.

---

## Three tiers

### PUBLIC (safe for the public GitHub repo)
- Business concept & positioning
- Sanitized architecture / high-level diagrams
- Fixture-only demos (clearly labeled `DEMO` / `NOT LIVE` / `ASSUMED`)
- Public-facing design rationale
- Strategy narrative (STRATEGY.md) — already public
- Sanitized project plan

### INTERNAL (private repo / Obsidian / wiki; never public without release review)
- **Full technical requirements baseline** (this and related)
- System boundary, domain model, kernel registry, verification gates
- Merchant interview data & research provenance
- Economics / margin models / pricing strategy
- Operational SOPs & runbooks
- Private schemas & the event ledger design
- Research uncertainty / decision log
- Internal roadmap & kanban state

### RESTRICTED (private + access-controlled; never public, ever)
- Credentials, API keys, secrets (secret store, never in repo)
- Contact data & consent records
- Campaign records & redemption history (live)
- Vendor contracts
- Pricing strategy details
- Proprietary automation / kernel engine internals beyond the sanitized summary
- Security details / threat model specifics

## The real leak vector: fixtures (Council amendment)
Fixtures built from real Lakeview/N Broadway research, "labeled DEMO," are **not anonymized** — real business names/addresses re-identify. Rules:
- Fixtures **fictionalize names** and **perturb metrics** (never copy a real merchant's address/phone/hours verbatim).
- CI **lints** the public fixture set to **block real names/addresses** from the research corpus.
- Any PUBLIC daemon artifact must carry **attribution labels** and pass the **no-overclaim gate** (a demo claiming "incremental" without a baseline is a gate failure, even as a demo).

## Working rule

- **Public repo** = business concept + sanitized architecture + fixture demos (anonymized).
- **Private repo/vault** = everything the agency runs on (the bore-down specs).
- **Restricted** = secrets/contacts/live-campaign/contracts — access-controlled, never committed where it could leak.
- **Pricing tier dedupe (Council):** per-merchant economics = RESTRICTED; the campaign *framework* = INTERNAL. Do not publish both at different tiers.

## Classification of the current bore-down artifacts

| Artifact | Tier |
|----------|------|
| STRATEGY.md (already in public repo) | PUBLIC |
| POPlar_PROJECT_PLAN.md (already public) | PUBLIC (sanitized) |
| Technical Requirements Baseline | INTERNAL |
| Process Kernel Registry | INTERNAL (kernel *names* could be sanitized to PUBLIC later; engine internals RESTRICTED) |
| System Boundary & Context | INTERNAL |
| Domain Model & Data Contract | INTERNAL |
| Verification & Release Gates | INTERNAL |
| This classification | INTERNAL |

## For review
1. Confirm kernel-registry names may be sanitized to PUBLIC in a later release (recommend: yes — the *concept* of "we run campaign operations via gated process kernels" is a credible public signal; the *exact schema/rules* stay INTERNAL).
2. Confirm the three-tier boundary is complete.
