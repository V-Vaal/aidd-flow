# Workflow Documentation

Modular workflow guide for the AIDD process. Use this index as your entry point.

## Contents

- [Overview](overview.md)
- [Audit](audit.md)
- [Intake](intake.md)
- [Plan](plan.md)
- [Implementation](implementation.md)
- [Review](review.md)
- [Governance](governance.md)
- [GitHub Signals](github-signals.md)
- [Gates](gates.md)
- [Debugging](debugging.md)
- [Troubleshooting](troubleshooting.md)

## Related Specifications

- INTAKE template requirements: `docs/quality/intake.md`
- PLAN template requirements: `docs/quality/technical-plan.md`

## Quick Reference

**Workflow Entry Points:**
- `prompts/start.md` - Start workflow (targeted or exploratory mode)
- `prompts/audit.md` - Repository audit
- `prompts/intake.md` - Create INTAKE.md
- `prompts/plan.md` - Create PLAN.md
- `bash scripts/validate-plan.sh` - Validate PLAN.md
- `prompts/review.md` - Create REVIEW.md
- `aidd/memory/activeContext.md` - Update activeContext.md
- `prompts/pr-message.md` - Generate PR message

**Scripts:**
- `bash scripts/validate-plan.sh` - Validate PLAN.md structure
- `bash scripts/aidd-check.sh` - Comprehensive validation
- `bash scripts/aidd-check.sh --plan` - Include PLAN.md validation
- `bash scripts/aidd-check.sh --review` - Include REVIEW.md validation
- `bash scripts/review-check.sh` - Validate REVIEW.md
- `bash scripts/aidd-verify-ui.sh` - UI verification (if frontend)
- `bash scripts/aidd-finish.sh` - Guided post-review closeout (optional)
- `bash scripts/validate-rules.sh` - Validate rules structure

**Artifacts:**
- `aidd/work/AUDIT.md` - Repository analysis
- `aidd/work/INTAKE.md` - Requirements and constraints
- `aidd/work/PLAN.md` - Technical implementation plan
- `aidd/work/REVIEW.md` - Review verdict and evidence
- `aidd/work/github-signals.md` - GitHub signals (targeted mode)
- `aidd/work/github-signals.config.yml` - GitHub signals configuration
