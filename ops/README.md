# Poplar.agency — Internal Operations Spec (INTERNAL)

**This directory is the internal campaign-operations technical spec.** Per the
Public/Internal classification (see `ops/specs/PUBLIC_INTERNAL_CLASSIFICATION.md`),
these artifacts are INTERNAL — they live in this **private** repository and are
not for public release without explicit review.

It turns "the agency experience" from a narrative into a runnable, auditable,
exception-based operating system: a daemon-LLM-agent executes routine process
kernels while humans hold every binding gate.

## Contents

| Path | Artifact | What it is |
|------|----------|-----------|
| `DECISIONS_LOG.md` | Decisions log | Binding decisions (D-001..D-023) + open items; authoritative per baseline §12 |
| `kernels/PROCESS_KERNEL_REGISTRY.md` | **Process Kernel Registry** | 28 kernels decomposing the campaign lifecycle into daemon-executable units (FR-701-708) |
| `specs/SYSTEM_BOUNDARY.md` | System Boundary & Context | What's in/out; interfaces I-1..I-7; trust boundaries |
| `specs/VERIFICATION_RELEASE_GATES.md` | Verification & Release Gates | Gates 0-5 as testable acceptance criteria; kernel quarantine; no-overclaim rule |
| `specs/STAGED_ROADMAP.md` | Staged Roadmap | 6 stages: spec → fixture slice → rehearsal → pilot → production |
| `specs/PUBLIC_INTERNAL_CLASSIFICATION.md` | Public/Internal Classification | 3-tier artifact policy + fixture anonymization |
| `specs/KANBAN_CROSSWALK.md` | Kanban ⇄ Repo ⇄ Wiki crosswalk | Layer linkage + next tasks |
| `domain/DOMAIN_MODEL_DATA_CONTRACT.md` | Domain Model & Data Contract | Concrete schema for 20+ entities + the append-only event ledger |
| `reviews/` | Three-body review verdicts | Locus + Council review of the suite (2026-08-20) |

## Authority chain

`DECISIONS_LOG.md` → `Technical Requirements Baseline` → `Operations Architecture`
→ `Project Plan` → Research → Kanban → GitHub (public = sanitized only).

## Status

- Suite drafted + three-body reviewed (Locus AMEND, Council KERNEL PRESERVED
  WITH RAISING), all amendments integrated.
- Binding bore-down decisions D-020..D-023 adopted on assumption (pending
  final Dallas confirmation).
- Next: **fixture vertical slice** (schema + ledger + kernel engine + surfaces).
