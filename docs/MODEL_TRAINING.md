# Synthetic model training

The project includes an offline, reproducible prototype trainer at
[`ml/train_trustscore.py`](../ml/train_trustscore.py). It compares Random Forest
and Extra Trees using a fixed seed, stratified train/validation/test splits,
missingness-aware median imputation, and a deterministic 0–1,000 score
conversion.

## Run

```bash
python3 -m venv .venv
. .venv/bin/activate
python -m pip install -r ml/requirements.txt
python -m ml.train_trustscore \
  --data ml/data/trustscore_training_dataset.csv \
  --output-dir ml/artifacts
```

The generated files are:

- `ml/artifacts/trustscore_model.joblib`: versioned prototype model bundle.
- `ml/artifacts/trustscore_model.json`: portable forest artifact loaded by the
  Flutter app for offline inference.
- `ml/artifacts/evaluation_report.json`: split sizes, candidate comparison,
  holdout metrics, feature importance, calibration, and limitations.

The model is selected by validation Brier score, with ROC-AUC as the tie-breaker.
The supplied dataset is synthetic and has no missing feature values; therefore
the trainer supports missingness but the generated report cannot validate
missingness-stratified behavior. Missing evidence must be handled by the
pathway selector before scoring: fewer than four present features returns
`insufficient_evidence`, not a low score.

This is not a lending model. The output is supplementary information only; 750
is a provisional display reference and never an approval or rejection
threshold.
