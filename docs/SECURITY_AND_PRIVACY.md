# Security and Privacy

## Scope

This document defines prototype safeguards and the controls required before any real deployment. It does not claim legal compliance, complete privacy, or zero retention.

## Data minimisation

Collect only what is needed for the demonstrated journey: a minimal account, country/configuration, consent state, synthetic evidence, assessment output, and support status. Do not collect raw National ID numbers, card details, bank credentials, unrelated demographic data, or raw financial transactions.

Separate identity fields from assessment features. Prefer provider references, verified flags, buckets, and aggregates. Synthetic data must be labelled and isolated from any future real-data path.

## Consent and lawful access

Consent screens must state categories, purpose, source, processing, retention, withdrawal/correction options, and limitations in understandable language. Record policy version, timestamp, actor, purpose, and status. Consent alone does not authorise restricted records; a future connector must enforce provider permissions and legal agreements.

Withdrawal must stop new access and trigger the documented retention/deletion policy. Existing outputs and audit records require a defined policy rather than silent deletion.

## Identity and authentication

Use a supported password hashing library, secure session/token handling, rate limiting, and generic authentication errors. Do not log passwords, tokens, raw identifiers, or sensitive payloads. Simulated identity verification must be visibly labelled and must not resemble a live government integration.

## Authorisation

Enforce role-based access on the server, not only in the UI. Institution reviewers require tenant isolation and least privilege. Applicants can view their own records; they cannot view another applicant's evidence or internal audit details. Programme administrators access assistance data only as required.

## Encryption and secrets

Use TLS for deployed connections and encrypted storage for sensitive production data. Keep secrets in environment/secret-management facilities, never in source control or fixtures. The prototype should use non-sensitive local configuration and provide an example environment file without secret values.

## Input and output safety

Validate all API input with typed schemas, constrain numeric ranges, validate file types if files are later added, and use parameterised queries/ORM APIs. Escape rendered user-controlled text. Return explicit, non-sensitive errors; do not fall back to a success-shaped response.

## Audit and monitoring

Record authentication events, consent changes, data-access attempts, assessment generation, model version, assistance decisions, and administrative changes. Redact payloads. Monitor unusual access, duplicate applications, provider anomalies, and repeated failed authentication. Audit records should be append-oriented and access-controlled.

## Fraud prevention

The prototype may demonstrate duplicate checks, simulated source verification, anomaly flags, and identity-status review. These are signals for human investigation, not automatic denial. Future production fraud detection needs validated data, appeal paths, and bias testing.

## Retention, deletion, and correction

Define retention by record category and purpose. Implement and test deletion/anonymisation for demo records. Support correction requests and preserve a clear history of changes without retaining unnecessary prior sensitive values. Never promise deletion or zero retention until the mechanism is verified.

## Threat priorities

- broken object-level authorization and institution data leakage;
- consent bypass or use after withdrawal;
- credential/token theft;
- sensitive data in logs or model artifacts;
- model or dataset tampering;
- score manipulation and replayed provider results;
- inference of sensitive attributes from explanations;
- denial of service and brute-force authentication;
- assistance-fund abuse.

## Security acceptance

Before presentation, run dependency/security checks available in the chosen stack, authorization tests, secret scans, validation tests, and a manual threat-model review. Any unresolved high-risk issue must be disclosed rather than hidden.
