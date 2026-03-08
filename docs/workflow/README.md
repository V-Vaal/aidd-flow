# Workflow Documentation

Modular workflow guide for the AIDD process.

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

## Quick Reference

### Prompts

- `prompts/start.md`
- `prompts/audit.md`
- `prompts/intake.md`
- `prompts/plan.md`
- `prompts/review.md`
- `prompts/compact-response.md`

### Validation scripts

- `bash scripts/validate-plan.sh`
- `bash scripts/aidd-check.sh`
- `bash scripts/review-check.sh`
- `bash scripts/aidd-verify-ui.sh` (if UI changes)

### Utility scripts

- `bash scripts/gh-context.sh ...` (GitHub signals)
- `bash scripts/c7-docs.sh --library <id> [--topic <topic>]` (Context7)
- `bash scripts/aidd-rules-jit.sh` (just-in-time rules)
- `bash scripts/aidd-diff-digest.sh` (compact diff digest)
- `bash scripts/aidd-finish.sh` (cycle closeout + handoff)

### Core artefacts

- `aidd/work/AUDIT.md`
- `aidd/work/INTAKE.md`
- `aidd/work/PLAN.md`
- `aidd/work/REVIEW.md`
- `aidd/work/SUMMARY.md`
- `aidd/work/HANDOFF.md`
- `aidd/work/DIFF_DIGEST.md`
- `aidd/work/RULES_JIT.md`
