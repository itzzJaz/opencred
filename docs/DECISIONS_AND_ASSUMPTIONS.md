# Decisions and Assumptions

## Confirmed decisions for the planning phase

| Decision | Rationale |
|---|---|
| Use a modular monolith for MVP | Small, understandable, demoable, and easier to test than distributed services. |
| Use synthetic applicants and records only | Prevents privacy exposure and avoids pretending to have institutional access. |
| Use simulated ID/data providers behind interfaces | Demonstrates integration boundaries without false partnership claims. |
| Preserve two first-class pathways | Missing evidence must not become an automatic negative judgement. |
| Keep TrustScore supplementary | Lending, affordability, and compliance remain with the institution. |
| Treat 750 as provisional | No threshold is valid before calibration and validation. |
| Separate assistance from assessment | Social support must not become a hidden score or lending incentive. |
| Prefer relational persistence | Consent, lineage, audit, and relationships need explicit integrity constraints. |

## Assumptions to validate

- The GIC demonstration can use a local browser application and seeded demo data.
- The team can support the recommended TypeScript/Python stack.
- No real personal or financial data is required for evaluation.
- Demonstration country configurations can be illustrative rather than jurisdictional claims.
- The eventual institution workflow will remain human-in-the-loop.

## Unresolved questions requiring approval

1. Should the approved implementation use React/FastAPI as recommended, or an alternative stack already preferred by the team?
2. Which country or countries should the demo configuration show, and what neutral wording is required for the presentation?
3. Which applicant roles and institution roles are needed in the demo?
4. What evidence sufficiency scenarios should be seeded for the presentation?
5. Should the model use a simple baseline plus Random Forest/Extra Trees, or only one tree ensemble to control scope?
6. What accessibility and language level is required for the target audience?
7. What fictional assistance eligibility and funding limits best communicate the social-impact mechanism?
8. Which retention/deletion behaviour must be visibly demonstrated versus documented only?

## Technical and operational risks

- Synthetic labels may create artificial patterns and overstate apparent performance.
- A score may be misunderstood as a loan approval or guarantee.
- Evidence thresholds may exclude people if designed carelessly.
- Country transfer may be invalid because data sources and behaviours differ.
- External integrations require legal agreements, security review, availability, and operational support.
- Financial assessment may trigger consumer-protection, privacy, fairness, and model-governance obligations.
- Fraud controls can unfairly burden vulnerable applicants without appeals and human review.
- An interest-assistance programme requires segregated governance, funding, eligibility, audit, and anti-fraud controls.
- Model explanations may leak sensitive information or imply unsupported causality.
- A student prototype cannot establish production accuracy, impact, or financial sustainability.

## Partnership and regulatory dependencies

Future deployment would require authorised National ID access, financial-data providers, participating institutions, lawful data processing, country-specific regulatory review, historical repayment outcomes, independent validation, and governance for assistance funds. None is assumed to exist.

## Future decisions

Production hosting, identity provider, database operations, observability, incident response, data retention periods, model approval process, pricing, institutional contracts, and impact measurement must be decided after prototype validation and stakeholder review.
