# Feature Specification

## Status vocabulary

Every feature must be marked `implemented`, `simulated`, or `future`. The MVP uses synthetic data and simulated external services.

## Applicant registration

The applicant creates a minimal account and selects a country/configuration. The system validates input, creates a role-scoped profile, and explains that this is a demonstration. It must not request unnecessary identity or financial information.

## Simulated identity verification

The applicant submits a fictional verification reference or selects a seeded scenario. The simulated provider returns verified, failed, or pending. The UI must state that no government system was contacted. A failed verification blocks protected assessment access and provides a clear next step; it is not a financial judgement.

## Consent management

Before evidence access, show purpose, categories, source, processing, retention, withdrawal, and limitations. Require an explicit action and record a versioned consent record. Allow the applicant to view status and withdraw. Withdrawal blocks new access.

## Evidence and pathway selection

The system summarises available evidence by type, recency, reliability, and verification state. It selects:

- **Pathway 1** when sufficient reliable evidence exists;
- **Pathway 2 alternative** when limited but potentially verifiable evidence exists;
- **Pathway 2 assisted access** when meaningful assessment cannot be produced.

Missing evidence must be explained neutrally and must not be mapped to a negative behaviour value.

## TrustScore assessment

For Pathway 1, generate an illustrative 0–1,000 score from the versioned synthetic model. Show the provisional 750 reference only as a non-binding demonstration benchmark. Show evidence status, model version, principal factors, gaps, limitations, and a prominent “not a loan decision” message.

Do not generate a score for insufficient evidence. Do not provide an approval, rejection, affordability result, or guarantee.

## Alternative assessment and support

Offer fictional verification steps such as documented informal income, cooperative repayment evidence, or small-business records. If adequate evidence is not established, show an assisted-access outcome and relevant fictional support referrals. The system must make clear that support availability depends on future partnerships and local rules.

## Applicant dashboard

Display identity status, consent history, evidence status, pathway, assessment/explanation or no-score reason, referral/support status, and correction/withdrawal controls. Use accessible language and avoid shaming users for missing records.

## Institution dashboard

An authorised reviewer can view assigned applicant assessments, evidence quality, explanations, model version, limitations, and audit events relevant to the review. The dashboard must state that the institution retains responsibility for affordability, eligibility, responsible lending, and the final decision. There is no automatic approval action.

## Interest-assistance programme

Provide a separate fictional application flow, transparent criteria, capped allocation, decision reason, funding source label, and audit view. It must be segregated from TrustScore and lending decisions. It is not a repayment guarantee, insurance product, or proof of real funding.

## Country configuration

Country selection changes demonstrative permitted indicators, language/configuration, and model metadata. It must show that real deployment requires local data, partnerships, regulatory review, calibration, and fairness validation.

## Error, accessibility, and privacy behaviour

Errors must be explicit and actionable. Sensitive values must be masked or omitted. Keyboard navigation, readable contrast, labels, focus management, and screen-reader semantics are required for primary journeys. Every feature must document what it stores and how it is tested.

## Out of scope for MVP

Live ID or bank integrations, real customer onboarding, loan origination, automatic lending decisions, real financial records, production fraud decisions, real funds, regulatory certification, and claims of predictive validity.
