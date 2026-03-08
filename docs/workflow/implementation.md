# Implementation Phase

Execute the plan under constraints and verify results before review.

## Implement

- Use your AI agent
- Follow rules in `rules/`
- Reference PLAN.md steps exactly
- Before coding against external libraries, run `bash scripts/c7-docs.sh ...` (mandatory)
- Keep `aidd/work/SUMMARY.md` concise and up to date

## Checks

- `bash scripts/aidd-check.sh`
- `bash scripts/aidd-verify-ui.sh` (if UI changes)

## Update Active Context

- Update `aidd/memory/activeContext.md` after successful modifications
- Document what was completed, current system state, next steps or open questions
