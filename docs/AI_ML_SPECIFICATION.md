# AI/ML Specification

## Purpose and limits

The prototype demonstrates an assessment pipeline, not a validated credit-risk product. All training and demo data must be synthetic. No predictive accuracy, partnership, regulatory approval, or production suitability may be claimed from prototype results.

## Assessment contract

The model receives an evidence feature set and returns either:

1. a score in the inclusive range 0–1,000 with model version, evidence status, explanation, and limitations; or
2. `insufficient_evidence`, with the missing/evidence-quality explanation and the alternative or assisted-access route.

The model output is supplementary information. It must not contain a loan approval, rejection, affordability conclusion, or guarantee.

## Candidate features

Use only relevant, permitted, and documented indicators, such as:

- verified income regularity over a defined synthetic period;
- utility payment consistency where the applicant is the named/verified payer;
- verified rental payment consistency;
- previous repayment outcomes where available;
- recognised financial activity counts or stability measures;
- income/expense coverage indicators where legally and ethically appropriate;
- evidence source, recency, reliability, and completeness metadata.

Do not use names, raw identity numbers, card numbers, unrelated sensitive attributes, or protected attributes as predictive inputs. Protected attributes may be retained in a controlled evaluation dataset solely for fairness analysis where lawful and necessary.

## Ollama scoring

The Flutter demonstration delegates TrustScore scoring to an Ollama model on
the operator's laptop (see the README). The adapter sends optional numeric
evidence and an optional plain-English description, requests structured JSON,
and maps the reply onto the assessment contract (0–1,000 score, model version,
factors, limitation). A relevant description can be scored without numeric
fields. There is no bundled scoring model or local inference fallback. An
Ollama result is a local demonstration output, not a validated model: it is
supplementary and cannot approve or reject a loan.

## TrustScore calibration

Ollama returns an integer from 0–1,000 directly. Store the configured model name and the profile-input hash with each cached result. The 750 reference is displayed as **provisional** and cannot be treated as a policy threshold. Any future threshold requires institutional, legal, fairness, and validation review.

## Explainability

Each scored assessment should expose a small set of principal positive and negative factors and a plain-language limitation. Explanations must not reveal secrets or imply causation beyond what the model supports.

## Country-adaptive configuration

Country configuration controls permitted indicators, evidence rules, and language. A new country requires local permissions, independent fairness review, and evaluation of Ollama outputs before use.

## Fairness and responsible use

Test whether data availability, evidence thresholds, and model outputs disadvantage groups. Compare outcomes for comparable evidence and separately inspect structural access gaps. Do not “fairness-adjust” by hiding a problem; investigate features, missingness, and process design. A no-score outcome is not a negative score and must have a dignified support path.

## Model governance

Store the Ollama model name, code version, profile-input hash, score-run outputs, timestamp, country configuration, and approval status with each result. Retain only the metadata needed for reproducibility and audit.
