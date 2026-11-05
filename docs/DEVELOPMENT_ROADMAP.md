# Development Roadmap

## Delivery order

Work should proceed in dependency order. A phase is complete only when its completion criteria and focused tests pass. No phase should silently introduce real integrations or real personal data.

## MVP definition

The minimum viable prototype is a coherent, end-to-end demonstration of:

- synthetic applicant registration;
- simulated National ID verification;
- explicit, reviewable consent;
- evidence sufficiency and both pathways;
- synthetic financial indicators;
- a clearly labelled illustrative TrustScore and explanation;
- no-score assisted access and support referral;
- institution review dashboard;
- separate interest-assistance demonstration;
- role boundaries, audit events, and documentation of limitations.

## Phases

### 1. Repository and architecture setup

- **Objective:** Establish the approved modular monolith and development commands.
- **Work:** Create frontend/backend/ml boundaries, configuration strategy, environment example, migration/testing skeleton, and local-only simulated providers.
- **Dependencies:** Approved plan and technology choice.
- **Testing:** Health check, configuration validation, import/type checks.
- **Done when:** A minimal app starts locally, no real integration is implied, and the README has verified commands.
- **Difficulty:** Avoiding premature production complexity while keeping boundaries useful.

### Demonstration frontend status

The offline Flutter frontend now covers the approved demonstration surface: welcome, applicant switching, simulated verification and consent states, CSV-backed financial evidence, both assessment pathways, institution review, interest assistance, settings, and demo reset. The AI model, backend, live providers, and lending decisions remain future work.

### 2. UI/UX design

- **Objective:** Make the two-pathway experience understandable and accessible.
- **Work:** Applicant journey, consent screens, evidence-status states, score explanation, no-score support route, institution view, assistance view.
- **Dependencies:** Feature specification and terminology.
- **Testing:** Keyboard/accessibility checks and component tests.
- **Done when:** Both pathways can be followed without ambiguous or punitive missing-data language.
- **Difficulty:** Communicating uncertainty without overwhelming users.

### 3. Database and backend foundation

- **Objective:** Persist minimal, role-separated records.
- **Work:** Schema, migrations, auth/RBAC, validation, audit events, consent lifecycle, error responses.
- **Dependencies:** Architecture and schema.
- **Testing:** API, authorization, consent withdrawal, validation, and migration tests.
- **Done when:** Protected endpoints enforce roles and all sensitive operations are auditable.
- **Difficulty:** Avoiding accidental exposure of identity data in logs and responses.

### 4. Synthetic data generation

- **Objective:** Provide reproducible, non-personal training and demo data.
- **Work:** Generator, seed/version metadata, missingness patterns, evidence-quality labels, documentation of limitations.
- **Dependencies:** AI/ML specification.
- **Testing:** Schema validation, reproducibility, missingness scenarios, leakage checks.
- **Done when:** No generated value resembles a real person's data and datasets are clearly synthetic.
- **Difficulty:** Synthetic correlations can create misleading confidence.

### 5. AI model development

- **Objective:** Evaluate a preliminary model without claiming real-world validity.
- **Work:** preprocessing, missingness-aware features, Random Forest and Extra Trees comparison, holdout evaluation, calibration, model artifact metadata.
- **Dependencies:** Synthetic data and model contract.
- **Testing:** Reproducible training, metric bounds, leakage checks, missing-data tests, baseline comparison.
- **Done when:** A versioned model can produce a score or an explicit no-score result with limitations.
- **Difficulty:** Synthetic labels do not establish production performance.

### 6. TrustScore implementation

- **Objective:** Expose a stable 0–1,000 supplementary score contract.
- **Work:** score conversion, provisional benchmark display, explanation, confidence/evidence status, model-version record.
- **Dependencies:** Model development and API foundation.
- **Testing:** score bounds, calibration fixtures, explanation consistency, no automatic decision paths.
- **Done when:** 750 is labelled provisional and no score is manufactured for insufficient evidence.
- **Difficulty:** Preventing a simple numeric display from being interpreted as approval.

### 7. Two-pathway assessment

- **Objective:** Implement inclusion logic as a first-class domain rule.
- **Work:** evidence sufficiency, alternative verification, assisted access, referral, applicant messaging.
- **Dependencies:** TrustScore contract and consent.
- **Testing:** boundary cases, missing-versus-negative data, pathway authorization, regression tests.
- **Done when:** every applicant reaches a documented outcome and insufficient evidence never becomes a low score.
- **Difficulty:** Defining evidence thresholds without pretending they are validated.

### 8. Applicant dashboard

- **Objective:** Give applicants control and understandable feedback.
- **Work:** status, consent history, data categories, assessment result/explanation, correction/withdrawal affordances, referrals.
- **Dependencies:** Backend, pathway logic, UX.
- **Testing:** authorization, content states, accessibility, end-to-end happy paths.
- **Done when:** applicants can understand what happened and why.
- **Difficulty:** Balancing transparency with sensitive-data minimisation.

### 9. Financial institution dashboard

- **Objective:** Demonstrate supplementary review without automated lending.
- **Work:** institution role, applicant assessment list, evidence and explanation panels, affordability/lending disclaimer, audit access.
- **Dependencies:** Applicant and assessment modules.
- **Testing:** tenant isolation, least privilege, no approval endpoint, audit trail.
- **Done when:** a reviewer can use the assessment as supplementary information only.
- **Difficulty:** Preventing institutional UI language from implying a guarantee.

### 10. Interest-assistance demonstration

- **Objective:** Demonstrate the social-impact mechanism separately from scoring.
- **Work:** fictional funding ledger, eligibility criteria, application, allocation limits, status and audit view.
- **Dependencies:** Auth, schema, UI.
- **Testing:** eligibility boundaries, duplicate/fraud scenarios, segregation from lending decisions.
- **Done when:** assistance is transparent, capped, auditable, and clearly not loan repayment insurance.
- **Difficulty:** Avoiding unsupported claims about funding or charitable status.

### 11. Security and fairness testing

- **Objective:** Test safeguards before presentation.
- **Work:** threat model, authorization matrix, input fuzzing, secrets review, retention/deletion checks, subgroup fairness metrics, explanation review.
- **Dependencies:** Integrated prototype.
- **Testing:** focused security and fairness test suite; manual review of high-risk flows.
- **Done when:** findings are recorded, critical issues are fixed or explicitly accepted, and limitations are visible.
- **Difficulty:** Synthetic subgroup results are illustrative only.

### 12. Final integration and GIC preparation

- **Objective:** Produce a reliable, honest demonstration.
- **Work:** seeded demo scenario, scripted two-pathway walkthrough, architecture slides, limitations and future-work narrative, smoke test.
- **Dependencies:** All prior phases.
- **Testing:** clean-machine setup, full focused suite, demo rehearsal.
- **Done when:** the demo works from documented commands and distinguishes implemented, simulated, and future features.
- **Difficulty:** Keeping the presentation compelling without overstating validation.

## Advanced future features

Authorised live data partnerships, real National ID verification, regulatory deployment, production monitoring, independently validated country models, lender integrations, live repayment outcomes, formal risk-sharing, and real assistance funds are future possibilities. They are outside the MVP.
