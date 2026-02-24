# Review Phase

Human audit required before marking work complete.

## Summary

- Prompt: `prompts/review.md`
- Output: `aidd/work/REVIEW.md` with Verdict (APPROVE | CHANGES_REQUESTED)
- Gate: `bash scripts/review-check.sh`

## Requirements

- Verdict must be exactly one of: `APPROVE` or `CHANGES_REQUESTED`
- Task is not done until Verdict is `APPROVE`
- Include test evidence (aidd-check.sh and aidd-verify-ui.sh if applicable)

## Finish Step (Optional)

After Verdict is `APPROVE`, you can run the guided closeout script:

```bash
bash scripts/aidd-finish.sh
```

It walks through:

- Commit / push / PR (with human confirmation and suggested commit message)
- Active context update
- Cleanup choice (archive via `aidd-cleanup.sh` vs purge work artifacts)
- Optional restart of INTAKE from review follow-ups
