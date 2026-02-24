# Active Context

> Updated after every completed task. Reflects the current state of work.

## Last Updated
2026-02-24T22:34:21Z

## Current Focus
Updated aidd-export to install into .aidd-flow with safe overwrite handling.

## Recently Completed
- Updated `scripts/aidd-export.sh` to export into `.aidd-flow/` by default with `--force/--backup` and AGENTS safeguards.
- Documented export behavior in `README.md` and `README.fr.md`.
- Updated `aidd/work/REVIEW.md` and ran `bash scripts/aidd-check.sh` and `bash scripts/review-check.sh`.

## Pending Decisions
- Whether to add CI gates for `validate-rules.sh` and `review-check.sh`.

## Next Steps
- Optional: test `bash scripts/aidd-export.sh` in a sandbox target.
- Optional: add CI gates for `validate-rules.sh` and `review-check.sh`.

## Blockers
None.

## Notes
- Review verdict is APPROVE for the aidd-finish helper addition.
