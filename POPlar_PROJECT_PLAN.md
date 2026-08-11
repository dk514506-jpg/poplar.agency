# Poplar.agency Project Plan

**Status:** ACTIVE / planning baseline  
**Last updated:** 2026-08-10  
**Purpose:** Durable reference for the Poplar.agency case-study campaign, product architecture, operating system, and agent collaboration model.

> **Public-example policy:** The four businesses are real public examples. Campaigns, offers, partnerships, endorsements, customer results, and participation are hypothetical until confirmed directly with each business. Every research note must label claims as `VERIFIED`, `UNVERIFIED`, `INFERENCE`, or `MERCHANT QUESTION`.

## 1. Outcome

Build a credible, reusable demonstration of Poplar.agency as a neighborhood marketing and customer-development service—not merely a social-media agency, discount marketplace, or crypto product.

The first demonstration will connect:

- Dots and Dashes — Korean bubble tea, egg sandwiches, and gimbap (user-provided description; verify public details).
- Chicago Sugar Daddy — bakery/patisserie example.
- Momo Factory — restaurant example; exact public details require verification.
- Lakeview Elegant Salon — hair-salon example.

The work must show both the customer-facing experience and the agency's ability to operate it profitably and responsibly.

## 2. Deliverables

1. Research dossier for each business and relevant local context.
2. Atmosphere/social/owned-web capability matrix.
3. Campaign brief and customer journey.
4. Merchant journey, staff playbook, support model, and reporting design.
5. Hardware/software/product/service catalog.
6. Campaign website prototype, clearly labeled as a concept.
7. Pitch-deck artifact and sample campaign materials.
8. Personal Poplar operating tools: leads, interviews, decisions, tasks, campaigns, content, hardware, and weekly review.
9. Obsidian project wiki and Kanban board.
10. Versioned source and verification notes in GitHub.

## 3. Working campaign hypothesis

Use one connected neighborhood campaign as the demonstration rather than four disconnected websites. Working name: **Lakeview Loop**. The name, geography, and campaign mechanics remain hypotheses until locations and merchant fit are verified.

Core loop:

> Discover → visit → collect/record → return → cross-visit → attend → refer.

Each merchant should have a distinct role, offer logic, operational burden, customer entry point, and success metric. Avoid invented prices, hours, menus, customer counts, testimonials, or campaign results.

## 4. Product/service architecture

### Front office

- Campaign landing pages and merchant pages.
- QR-first, NFC-enhanced entry points; no mandatory app download.
- Mobile customer passport or membership view.
- Events, routes, offers, and public stories.
- Email/SMS/Wallet follow-up only with consent.
- Social distribution through existing channels plus open/owned alternatives.

### Merchant operations

- Onboarding and slow-period diagnosis.
- Offer and reward design with margin guardrails.
- Staff verification page and simple physical ritual.
- Content capture and publishing.
- Event or route activation.
- Consent-aware follow-up.
- Monthly reporting: acquisition, redemption, repeat behavior, cross-visits, referrals, contribution-margin estimate, and staff time.

### Back office

- Merchant CRM and lead pipeline.
- Campaign registry and versioned briefs.
- Offer/reward rules.
- Redemption and anti-abuse ledger.
- Hardware inventory and serials.
- Source/evidence library.
- Support queue and incident log.
- Reporting pipeline.
- Decision log and change history.

### Technology posture

Start with ordinary web, QR, a private operational ledger, and manual staff verification. Add Wallet passes, credentials, secure NFC, custom AT records, or deeper integrations only when a validated behavior justifies them. Public publishing and discovery must not become the system of record for private customer data.

## 5. Atmosphere and social strategy

Investigate the user's candidate set—Roomy, Skilld, Inlay, Taproot, ATP.tools, PDSs, comail, airglow, and aether—without assuming availability, maturity, semantics, or suitability. For each, record:

- verified purpose and current status;
- protocol/data model;
- front-office or back-office fit;
- merchant/customer value;
- integration effort;
- privacy and reliability risks;
- fallback/export path;
- whether it belongs in the pilot, later production, or research only.

Also evaluate a resilient distributed stack:

- Poplar-owned web as the customer-facing source.
- Existing platforms for reach.
- AT Protocol/Atmosphere for open publishing/discovery where useful.
- Smoke Signal or equivalent for events where appropriate.
- Email/SMS and Wallet for dependable retention.
- Optional ActivityPub/Mastodon federation or other open-web distribution.

Principle: use rented platforms for reach, but Poplar-owned systems for campaign rules, consent, measurement, and support.

## 6. Agent council

### Main Hermes orchestrator

Owns project context, decomposition, budget, secrets, canonical plan, architecture-of-record, final synthesis, user-facing decisions, artifact verification, Git integration, and stop/go gates. No sub-agent output is accepted without checking its actual file, diff, URL, or structured result.

### Hermes sub-agent

Handles bounded independent research, deeper source inspection, code/tool scaffolding, and implementation tasks in isolated workspaces. It returns evidence-linked artifacts or drafts, not unverified claims.

### DeepSeek V4 Flash

Use for cost-efficient broad research synthesis, comparative matrices, structured extraction, adversarial alternative generation, and first-pass drafting from supplied evidence. It must not be the final authority on facts; unsupported claims are flagged for verification.

### Low-cost QA/systems model

Use a Haiku-class or equivalent model only for short, bounded QA and mechanical transformations: schema checks, link/citation audits, checklist validation, consistency review, template scaffolding, and concise defect reports. It should not own strategy, creative direction, secrets, or irreversible changes.

### Human/user

Owns real-world access, relationship judgment, ethical boundaries, merchant contact, final positioning, spending approval, and taste decisions. The project should ask the user only when a choice materially changes the architecture, cost, or external claim.

## 7. Handoff contract

Every delegated task must state:

- objective;
- inputs and source boundary;
- evidence standard;
- exact output format/path;
- token/turn/time budget;
- forbidden actions;
- verification test;
- escalation condition.

Default sequence:

1. Orchestrator writes brief.
2. Researcher/builder produces an artifact.
3. QA model checks the artifact mechanically.
4. Orchestrator verifies, resolves conflicts, and updates canonical sources.
5. User receives only the synthesized result and the next meaningful decision.

No agent should converse merely to simulate collaboration. Communication must reduce uncertainty, create an artifact, identify a conflict, or trigger a decision.

## 8. Cost and halting policy

Before any expensive action:

1. State the smallest useful action.
2. Forecast likely token/API cost qualitatively or numerically when known.
3. Reduce scope, turns, context, and output before launching.
4. Prefer deterministic scripts and existing files over another model call.
5. Batch independent questions.
6. Reuse verified evidence and cached context.
7. Stop when acceptance criteria pass and another iteration is unlikely to improve the outcome.

Do not use a powerful model for formatting, file enumeration, link checking, or repetitive transformations. Do not launch parallel agents when the task is sequential or mechanical. Do not build production infrastructure before the pilot behavior and willingness to pay are validated.

## 9. Engineering and verification standards

- Git is the source-control boundary; use small commits with descriptive messages.
- Keep public claims sourced and dated.
- Separate public records from private customer/transaction data.
- Use QR fallback for every NFC flow.
- Design for export and vendor replacement.
- Make interfaces and schemas explicit before integration.
- Prefer additive, reversible changes.
- Test links, HTML parsing, JavaScript syntax, responsive behavior, and data assumptions mechanically where possible.
- Label demo data as `ASSUMED`, `DEMO`, or `NOT LIVE`.
- Verify every claimed deliverable on disk and remotely before reporting completion.

## 10. Phases and gates

### Phase A — evidence

Research the four businesses, locations, services, public channels, neighborhood relationship, and candidate Atmosphere apps.

**Gate:** no client-facing factual claim without a source label.

### Phase B — campaign and operations

Define the campaign loop, merchant roles, offer economics, support boundaries, hardware, software, data, and KPIs.

**Gate:** a staff member can understand the required action quickly, and the offer has explicit margin/abuse assumptions.

### Phase C — prototype

Build the campaign website, customer flow, merchant/staff view, pitch deck, and report mockup.

**Gate:** primary flow works without an app download; concept status is visible; mobile and desktop are usable.

### Phase D — internal operating system

Build the wiki, Kanban workflow, templates, CRM/task structures, campaign checklist, and review cadence.

**Gate:** a future campaign can be initialized from templates without reconstructing the system.

### Phase E — review and iterate

Run UX, merchant-operability, evidence, security/privacy, and engineering checks. Fix only defects that improve comprehension, credibility, safety, or reusability.

## 11. Current task board

The dedicated Hermes Kanban board is `poplar-agency`. Its initial tasks are:

- Research four real-business case studies.
- Map Atmosphere and owned-web stack.
- Define campaign and operations architecture.
- Build campaign website and pitch artifacts.

The board is the execution queue; this plan is the architecture-of-record. Obsidian is the linked knowledge layer; GitHub is the versioned artifact layer.

## 12. Reference repositories

- Poplar project: `git@github.com:dk514506-jpg/poplar.agency.git`
- Harness/lab: `git@github.com:dk514506-jpg/hermes-lab.git`

Use `hermes-lab` as a reference for harness experiments, reusable skills, verification patterns, and agent workflow improvements. Do not modify it unless a specific improvement is scoped, tested, and clearly beneficial to this project.

## 13. Open decisions

- Confirm the geographic relationship among the four businesses.
- Decide whether “Lakeview Loop” remains the campaign name.
- Decide which customer behavior is primary: slow-period fill, cross-business discovery, repeat visits, events, or referrals.
- Confirm desired Poplar visual identity.
- Decide the first prototype surface: customer campaign, merchant operations, or agency pitch.
- Decide which Atmosphere components are pilot candidates versus research-only.
- Establish private storage for prospect/contact information.

## Related notes

- [[Poplar Home]]
- [[Poplar Agent Council]]
- [[Poplar Atmosphere Research]]
- [[Poplar Campaign Lakeview Loop]]
- [[Poplar Operations Architecture]]
- [[Poplar Decisions]]
