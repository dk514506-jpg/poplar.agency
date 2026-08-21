# Poplar.agency — Kanban ↔ Repository ↔ Wiki Crosswalk (v0.1)

**Status:** INTERNAL · DRAFT for review · 2026-08-20
**Authority:** Build Clarification Q (private-Git arrangement) + baseline §13.
**Purpose:** Map the execution state (Kanban), the durable knowledge (wiki/vault),
and the versioned artifacts (private repo + public GitHub) so nothing is stranded.

---

## The four layers (per the private-Git decision)

| Layer | What it is | Writes |
|-------|-----------|--------|
| **Kanban** | live execution database (tasks, deps, status, handoffs) | current state only |
| **Wiki/Obsidian vault** | durable knowledge, decisions, rationale, research provenance | append/decide |
| **Private repo** | versioned control boundary (private specs + wiki mirror) | commits |
| **Public GitHub** | sanitized public projection | explicit release only |

## Current Kanban state (board `poplar-agency`)

| Task | Status | Attachment |
|------|--------|-----------|
| t_cd635782 — Research four real-business case studies | done | case-study-verification.md |
| t_99939907 — Map Atmosphere and owned-web stack | done | atmosphere-stack.md |
| t_b2bc606a — Define campaign and operations architecture | done | campaign-operations-architecture.md |
| t_e98990f3 — Build campaign website and pitch artifacts | done | project-plan.html |

## Next tasks this bore-down implies (to add to Kanban)

| Proposed task | Depends on | Maps to |
|---------------|-----------|---------|
| Locus/Council review of bore-down suite | (this pass) | Stage 0 |
| Implement schema + append-only ledger (fixture) | review approval | Stage 1, FR-401..405 |
| Implement kernel runner (READY→…→QUARANTINED) | schema | Stage 1, FR-701..708 |
| Build admin/staff/customer surfaces | kernel runner | Stage 1, I-1/I-2/I-4 |
| Generate fixture data from Lakeview market data | schema | Stage 1, Q5 |
| Three end-to-end rehearsals | fixture slice | Stage 2, Gate 1 |
| Live pilot (post-merchant-permission) | rehearsal | Stage 3, Gate 4/5 |

## Repository layout proposal (private repo ~/poplar-ops)

```
poplar-ops/
├── README.md            (pointer; INTERNAL)
├── decisions/           (Poplar Decisions log — mirrored to wiki)
├── specs/               (SYSTEM_BOUNDARY, VERIFICATION_GATES,
│                         PUBLIC_INTERNAL_CLASSIFICATION, STAGED_ROADMAP)
├── kernels/             (PROCESS_KERNEL_REGISTRY + future kernel definitions)
├── domain/              (DOMAIN_MODEL_DATA_CONTRACT)
├── fixtures/            (demo data generators, labeled DEMO/NOT LIVE)
└── (later) engine/, surfaces/, tests/
```

Public GitHub receives only **PUBLIC-tier** artifacts (see PUBLIC_INTERNAL_CLASSIFICATION.md).

## Crosswalk rule
- Every Kanban task completion → wiki decision/artifact + (where applicable) private-repo commit.
- Every private-repo commit of a PUBLIC-tier artifact → candidate for public GitHub after release review.
- Nothing is "done" until it exists on disk and is verifiable (the cross-project discipline).

## For review
1. Confirm ~/poplar-ops as the private repo home (vs a repo rooted at a future Obsidian vault).
2. Confirm the proposed next-task set for the Kanban board.
