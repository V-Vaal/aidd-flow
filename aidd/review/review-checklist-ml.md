# ML Review Checklist

## Data Leakage

- [ ] No data leakage between train/validation/test sets
- [ ] Preprocessing steps applied consistently across splits
- [ ] Target variable is not included in features
- [ ] Time-based leakage is prevented (if applicable)

## Train/Val/Test Split

- [ ] Proper data splitting strategy is documented
- [ ] Split ratios are appropriate for dataset size
- [ ] Stratification is used for imbalanced datasets (if applicable)
- [ ] Test set is held out completely until final evaluation

## Reproducibility (Seeds)

- [ ] Random seeds are set and documented
- [ ] Seeds are set for all random operations (numpy, pytorch, tensorflow, etc.)
- [ ] Reproducibility is verified across runs
- [ ] Seed values are stored in configuration

## Dataset Provenance

- [ ] Dataset source and version are documented
- [ ] Data collection methodology is described
- [ ] Data quality checks are performed
- [ ] Data licensing and usage rights are verified

## Metrics Definition

- [ ] Evaluation metrics are appropriate for the problem
- [ ] Metrics are clearly defined and documented
- [ ] Baseline metrics are established
- [ ] Business metrics are considered (if applicable)

## Overfitting Checks

- [ ] Training and validation loss curves are monitored
- [ ] Early stopping is implemented (if applicable)
- [ ] Model complexity is appropriate for dataset size
- [ ] Regularization techniques are applied (if needed)

## Configuration Tracking

- [ ] All hyperparameters are logged
- [ ] Model architecture is versioned
- [ ] Training configuration is reproducible
- [ ] Experiment tracking tool is used (MLflow, Weights & Biases, etc.)

## Baseline Comparison

- [ ] Baseline model performance is established
- [ ] New model is compared against baseline
- [ ] Improvement is statistically significant (if applicable)
- [ ] Trade-offs are documented (accuracy vs. speed, etc.)
