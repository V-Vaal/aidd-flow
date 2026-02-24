# Gates and Checkpoints

Validation scripts that enforce workflow boundaries.

## Core Gates

1. **Plan validation**
   - `bash scripts/validate-plan.sh`
   - Blocks implementation if PLAN.md is invalid

2. **Implementation checks**
   - `bash scripts/aidd-check.sh`
   - Validates project state after implementation

3. **Review validation**
   - `bash scripts/review-check.sh`
   - Blocks completion if REVIEW.md verdict is missing or invalid

## Supporting Gates

- `bash scripts/aidd-verify-ui.sh` — UI verification (when UI changes)
- `bash scripts/validate-rules.sh` — Rules structure validation

## Gate Behavior

- Gates are mandatory. If a gate fails, stop and fix the issue.
- Gates provide auditable evidence for the review phase.
