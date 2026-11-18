#!/usr/bin/env python3
"""Train and evaluate the synthetic TrustScore model.

This script is intentionally an offline prototype trainer. It does not make
lending decisions and emits no score when the evidence sufficiency contract is
not met at inference time.
"""

from __future__ import annotations

import argparse
import json
import platform
from datetime import UTC, datetime
from pathlib import Path
from typing import Any, Mapping

import joblib
import numpy as np
import pandas as pd
import sklearn
from sklearn.compose import ColumnTransformer
from sklearn.ensemble import ExtraTreesClassifier, RandomForestClassifier
from sklearn.impute import SimpleImputer
from sklearn.inspection import permutation_importance
from sklearn.metrics import (
    accuracy_score,
    average_precision_score,
    brier_score_loss,
    precision_score,
    recall_score,
    roc_auc_score,
)
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline

SEED = 20261109
DATASET_VERSION = "trustscore-training-v1"
MODEL_VERSION = "trustscore-synthetic-v1"
CALIBRATION_VERSION = "linear-probability-v1"
TARGET = "repayment_outcome"
ID_COLUMN = "applicant_id"
FEATURES = [
    "utility_payment_consistency_pct",
    "rent_payment_reliability_pct",
    "previous_loan_repayment_history",
    "missed_payments_count_12m",
    "verified_income_regularity_pct",
    "existing_financial_obligations_ratio",
]
MIN_FEATURES_FOR_SCORE = 4


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--data", type=Path, required=True, help="Synthetic CSV dataset")
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=Path("ml/artifacts"),
        help="Directory for the model and evaluation report",
    )
    return parser.parse_args()


def load_dataset(path: Path) -> pd.DataFrame:
    frame = pd.read_csv(path)
    required = {ID_COLUMN, TARGET, *FEATURES}
    missing = required.difference(frame.columns)
    if missing:
        raise ValueError(f"Dataset is missing required columns: {sorted(missing)}")
    if frame.empty:
        raise ValueError("Dataset must contain at least one row")
    if frame[ID_COLUMN].duplicated().any():
        raise ValueError("Applicant IDs must be unique")
    for column in FEATURES:
        frame[column] = pd.to_numeric(frame[column], errors="coerce")
    if frame[TARGET].isna().any() or not set(frame[TARGET].dropna().unique()).issubset({0, 1}):
        raise ValueError(f"{TARGET} must contain only binary 0/1 labels")
    return frame


def make_pipeline(model: Any) -> Pipeline:
    preprocessor = ColumnTransformer(
        [(
            "numeric",
            Pipeline([
                ("imputer", SimpleImputer(strategy="median", add_indicator=True)),
            ]),
            FEATURES,
        )],
        remainder="drop",
    )
    return Pipeline([("preprocessor", preprocessor), ("model", model)])


def metric_report(y_true: pd.Series, probabilities: np.ndarray) -> dict[str, float]:
    predictions = (probabilities >= 0.5).astype(int)
    return {
        "roc_auc": round(float(roc_auc_score(y_true, probabilities)), 4),
        "average_precision": round(float(average_precision_score(y_true, probabilities)), 4),
        "brier_score": round(float(brier_score_loss(y_true, probabilities)), 4),
        "accuracy": round(float(accuracy_score(y_true, predictions)), 4),
        "precision": round(float(precision_score(y_true, predictions, zero_division=0)), 4),
        "recall": round(float(recall_score(y_true, predictions, zero_division=0)), 4),
    }


def calibrated_score(probability: float) -> int:
    """Convert a probability to the documented provisional 0-1,000 range."""
    return max(0, min(1000, round(probability * 1000)))


def export_portable_model(bundle: dict[str, Any], output_dir: Path) -> None:
    """Export the fitted forest in a small JSON format understood by Flutter."""
    forest = bundle["model"].named_steps["model"]
    trees = []
    for estimator in forest.estimators_:
        tree = estimator.tree_
        nodes = []
        for node in range(tree.node_count):
            nodes.append({
                "feature": int(tree.feature[node]),
                "threshold": float(tree.threshold[node]),
                "left": int(tree.children_left[node]),
                "right": int(tree.children_right[node]),
                "negative": float(tree.value[node][0][0]),
                "positive": float(tree.value[node][0][1]),
            })
        trees.append(nodes)
    (output_dir / "trustscore_model.json").write_text(
        json.dumps({
            "model_version": bundle["model_version"],
            "calibration_version": bundle["calibration_version"],
            "feature_names": FEATURES,
            "medians": bundle["medians"],
            "min_features_for_score": bundle["min_features_for_score"],
            "trees": trees,
        }, separators=(",", ":")) + "\n",
        encoding="utf-8",
    )


def assess(bundle: Mapping[str, Any], evidence: Mapping[str, float | None]) -> dict[str, Any]:
    """Apply the evidence gate and score one synthetic assessment."""
    row = {feature: evidence.get(feature) for feature in FEATURES}
    present = sum(value is not None and not pd.isna(value) for value in row.values())
    if present < int(bundle["min_features_for_score"]):
        return {
            "status": "insufficient_evidence",
            "model_version": bundle["model_version"],
            "present_features": present,
            "required_features": bundle["min_features_for_score"],
            "limitation": "Missing evidence is not treated as negative financial behaviour.",
        }
    probability = float(bundle["model"].predict_proba(pd.DataFrame([row]))[0, 1])
    return {
        "status": "scored",
        "model_version": bundle["model_version"],
        "score": calibrated_score(probability),
        "probability": round(probability, 6),
        "present_features": present,
        "limitation": "Supplementary prototype output; not a lending or affordability decision.",
    }


def train(data: pd.DataFrame, output_dir: Path) -> dict[str, Any]:
    output_dir.mkdir(parents=True, exist_ok=True)
    x = data[FEATURES]
    y = data[TARGET].astype(int)
    x_train, x_holdout, y_train, y_holdout = train_test_split(
        x, y, test_size=0.2, random_state=SEED, stratify=y
    )
    x_validation, x_test, y_validation, y_test = train_test_split(
        x_holdout, y_holdout, test_size=0.5, random_state=SEED, stratify=y_holdout
    )

    candidates = {
        "random_forest": make_pipeline(
            RandomForestClassifier(
                n_estimators=400, min_samples_leaf=3, random_state=SEED, class_weight="balanced"
            )
        ),
        "extra_trees": make_pipeline(
            ExtraTreesClassifier(
                n_estimators=400, min_samples_leaf=3, random_state=SEED, class_weight="balanced"
            )
        ),
    }
    validation_metrics: dict[str, dict[str, float]] = {}
    for name, candidate in candidates.items():
        candidate.fit(x_train, y_train)
        validation_metrics[name] = metric_report(
            y_validation, candidate.predict_proba(x_validation)[:, 1]
        )

    selected_name = min(
        validation_metrics,
        key=lambda name: (
            validation_metrics[name]["brier_score"],
            -validation_metrics[name]["roc_auc"],
        ),
    )
    selected = candidates[selected_name]
    selected.fit(pd.concat([x_train, x_validation]), pd.concat([y_train, y_validation]))
    test_probabilities = selected.predict_proba(x_test)[:, 1]

    permutation = permutation_importance(
        selected, x_test, y_test, n_repeats=10, random_state=SEED, scoring="roc_auc"
    )
    importance = {
        feature: round(float(value), 4)
        for feature, value in sorted(
            zip(FEATURES, permutation.importances_mean), key=lambda item: item[1], reverse=True
        )
    }
    missing_counts = data[FEATURES].isna().sum().to_dict()
    report = {
        "dataset": {
            "version": DATASET_VERSION,
            "rows": len(data),
            "features": FEATURES,
            "class_counts": {str(key): int(value) for key, value in y.value_counts().sort_index().items()},
            "missing_values_by_feature": {key: int(value) for key, value in missing_counts.items()},
            "synthetic_only": True,
        },
        "split": {"train": len(x_train), "validation": len(x_validation), "test": len(x_test)},
        "selection": {
            "candidates": ["random_forest", "extra_trees"],
            "selected_model": selected_name,
            "selection_rule": "lowest validation Brier score, then highest ROC-AUC",
            "validation_metrics": validation_metrics,
        },
        "test_metrics": metric_report(y_test, test_probabilities),
        "calibration": {
            "version": CALIBRATION_VERSION,
            "formula": "score = clamp(round(predicted_probability * 1000), 0, 1000)",
            "provisional_reference": 750,
        },
        "explainability": {
            "method": "test-set permutation importance",
            "importance": importance,
            "limitation": "Importance is global association, not causation or an individual explanation.",
        },
        "evidence_contract": {
            "minimum_present_features_for_score": MIN_FEATURES_FOR_SCORE,
            "missing_features_are_not_negative": True,
            "insufficient_evidence_result": "insufficient_evidence",
        },
        "governance": {
            "model_version": MODEL_VERSION,
            "training_seed": SEED,
            "trained_at_utc": datetime.now(UTC).isoformat(),
            "python": platform.python_version(),
            "scikit_learn": sklearn.__version__,
            "approval_status": "prototype_only",
        },
        "limitations": [
            "Labels and records are synthetic demonstration data.",
            "This report does not establish production accuracy, fairness, regulatory approval, or lending suitability.",
            "The supplied dataset has no missing feature values; missingness behavior requires separate evaluation data.",
        ],
    }
    bundle = {
            "model": selected,
            "feature_names": FEATURES,
            "model_version": MODEL_VERSION,
            "calibration_version": CALIBRATION_VERSION,
            "min_features_for_score": MIN_FEATURES_FOR_SCORE,
            "medians": {feature: float(data[feature].median()) for feature in FEATURES},
        }
    joblib.dump(bundle, output_dir / "trustscore_model.joblib")
    export_portable_model(bundle, output_dir)
    (output_dir / "evaluation_report.json").write_text(
        json.dumps(report, indent=2) + "\n", encoding="utf-8"
    )
    return report


def main() -> None:
    args = parse_args()
    report = train(load_dataset(args.data), args.output_dir)
    print(json.dumps({
        "selected_model": report["selection"]["selected_model"],
        "test_metrics": report["test_metrics"],
        "artifacts": [str(args.output_dir / "trustscore_model.joblib"), str(args.output_dir / "evaluation_report.json")],
    }, indent=2))


if __name__ == "__main__":
    main()
