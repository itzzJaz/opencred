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

## Synthetic dataset

The generator should define a seed, schema version, country configuration, feature distributions, missingness mechanism, and label-generation method. It should include:

- applicants with strong, mixed, and weak evidence;
- missing-at-random and structurally missing indicators;
- applicants with no conventional history but reliable alternative evidence;
- applicants with insufficient evidence;
- subgroup labels reserved for fairness analysis;
- contradictory and stale records for quality testing.

Synthetic labels are demonstration labels created by an explicit documented process. They must not be presented as real repayment outcomes.

## Preprocessing and missingness

Missingness must be represented separately from negative values. Use feature-presence, source-quality, and recency indicators where useful. Imputation must be fitted on training data only and must not silently convert “not available” into “poor”. A missing feature may reduce evidence sufficiency without reducing a score.

The pathway selector runs before scoring. A model must not emit a low score merely because the evidence threshold is not met.

## Models and evaluation

Evaluate at least Random Forest and Extra Trees against a simple documented baseline. Use train/validation/test separation, fixed seeds, and model metadata. Report:

- discrimination metrics appropriate to the synthetic label;
- precision and recall;
- calibration and score distributions;
- subgroup false-positive/false-negative rates where sample sizes allow;
- missingness-stratified results;
- limitations and confidence intervals where meaningful.

These are prototype measurements only. Do not select a model solely on aggregate accuracy.

## TrustScore calibration

The raw model output must be transformed through a versioned calibration function into 0–1,000. Calibration must be deterministic and tested at boundaries. The 750 reference is displayed as **provisional** and cannot be treated as a policy threshold. Any future threshold requires institutional, legal, fairness, and validation review.

## Explainability

Each scored assessment should expose a small set of principal positive and negative contributing indicators, their availability/quality, and a plain-language limitation. Explanations must not reveal secrets or imply causation beyond what the model supports. For tree models, use stable model-native importance or a carefully validated explanation method; document its limitations.

## Country-adaptive configuration

Country configuration controls permitted indicators, model version, evidence rules, and language. It must not silently reuse a model trained in another country. A new country requires local data, permissions, calibration, independent performance/fairness testing, and review.

## Fairness and responsible use

Test whether data availability, evidence thresholds, and model outputs disadvantage groups. Compare outcomes for comparable evidence and separately inspect structural access gaps. Do not “fairness-adjust” by hiding a problem; investigate features, missingness, and process design. A no-score outcome is not a negative score and must have a dignified support path.

## Model governance

Store dataset version, code version, feature schema, model artifact identifier, training seed, evaluation report, calibration version, country configuration, and approval status. Never overwrite a model used by a recorded assessment. Retain only the metadata needed for reproducibility and audit.
