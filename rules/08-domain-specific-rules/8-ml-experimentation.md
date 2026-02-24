# 8 ml experimentation

Experiment Structure:
- Organize experiments in dedicated directories
- Use consistent naming for experiment runs
- Separate experiment configs from code
- Store experiment outputs systematically
- Document experiment objectives clearly
- Use version control for experiment code
- Keep experiment code modular

Logging Patterns:
- Log all hyperparameters at experiment start
- Log training progress at regular intervals
- Log validation metrics after each epoch
- Log model architecture details
- Log data preprocessing steps
- Log system information (GPU, memory)
- Use structured logging formats

Model Artifacts:
- Save model checkpoints regularly
- Version all model artifacts
- Store model metadata with artifacts
- Include training configuration with models
- Save model weights and architecture separately
- Document model artifact format
- Never overwrite model artifacts

Comparisons:
- Compare experiments on same test set
- Use consistent evaluation metrics
- Document all experimental conditions
- Track experiment lineage and dependencies
- Compare baseline and improved models
- Report statistical significance when applicable
- Visualize comparison results clearly

Experiment Reproducibility:
- Record all random seeds used
- Document environment and dependencies
- Save exact data splits used
- Log all preprocessing transformations
- Store experiment configuration files
- Version control experiment scripts
- Document any manual interventions
