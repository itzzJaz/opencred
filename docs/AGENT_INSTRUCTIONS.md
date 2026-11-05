# OpenCred Agent Instructions

## Mission

OpenCred is an AI-powered financial inclusion platform proposal. It provides supplementary, explainable financial-behaviour assessment while treating applicants with insufficient evidence fairly. It is not an ordinary credit-scoring or automatic loan-approval application.

## Required context

Before changing a component, consult the relevant documentation:

- overall scope and terminology: `PROJECT_OVERVIEW.md`;
- interfaces and module boundaries: `TECHNICAL_ARCHITECTURE.md`;
- behaviour and acceptance criteria: `FEATURE_SPECIFICATION.md`;
- data/model changes: `AI_ML_SPECIFICATION.md` and `DATABASE_SCHEMA.md`;
- sensitive-data or access changes: `SECURITY_AND_PRIVACY.md`;
- sequencing and scope: `DEVELOPMENT_ROADMAP.md`;
- unresolved choices and risks: `DECISIONS_AND_ASSUMPTIONS.md`.

Update the relevant documentation when behaviour, schema, architecture, model, privacy, or risk changes.

## Non-negotiable domain rules

1. The two pathways are core:
   - sufficient reliable evidence may receive a TrustScore;
   - limited/no evidence receives alternative assessment, assisted access, or referrals.
2. Missing data is not negative data.
3. TrustScore is 0–1,000, supplementary, explainable, and versioned.
4. 750 is provisional and must never be presented as a validated approval threshold.
5. Never hardcode a score as if it were an AI prediction.
6. Never automatically approve or reject a loan from TrustScore.
7. Institutions retain affordability, eligibility, lending, and compliance responsibility.
8. Never use real personal financial information in the prototype.
9. Clearly label simulated identity/data integrations and synthetic results.
10. Do not claim privacy, retention, accuracy, partnerships, funding, or regulatory approval without an implemented and verified basis.

## Coding and security conventions

- Prefer small, typed modules and meaningful names.
- Validate all external input at boundaries.
- Enforce authentication and authorization on the server.
- Keep identity data separate from assessment features where feasible.
- Use parameterized database access and secure password/token handling.
- Never log secrets, credentials, raw identity numbers, or sensitive payloads.
- Produce explicit errors; do not silently default or return success-shaped fallbacks.
- Preserve model and dataset versions for every assessment.
- Keep assistance data and decisions separate from TrustScore.
- Add focused tests for every changed rule, especially missing-data and authorization cases.

## Implementation discipline

Do not begin implementation until the planning phase is explicitly approved. Do not install dependencies without a concrete requirement. Do not replace existing work; inspect and integrate it. Do not add a production integration as a shortcut for a simulation.

When adding a feature:

1. identify its user-facing behaviour and data needs;
2. check scope, risks, and dependencies in the reference docs;
3. update the relevant specification and schema;
4. implement the smallest modular change;
5. add tests for normal, missing-data, unauthorized, and error cases;
6. run the documented checks;
7. record a decision or unresolved question if architecture changes.

## Running and testing

The repository is currently documentation-only, so implementation commands do not yet exist. Once code is approved, document exact setup, run, lint, type-check, model-training, migration, and test commands in the README. A future agent must not invent successful commands or claim tests passed without running them.

## Presentation integrity

Every demo screen and presentation should distinguish:

- implemented prototype behaviour;
- simulated integrations and fictional data;
- future deployment possibilities requiring partnerships or regulatory approval.

The goal is responsible, credible financial inclusion—not maximising score volume or loan volume.
