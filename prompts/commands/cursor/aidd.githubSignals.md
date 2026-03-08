# Cursor Command (Archived) — aidd.githubSignals

Generate `.cursor/work/github-signals.md` using gh CLI facts only.

## Inputs

- `.cursor/work/github-signals.config.yml` (repo + optional target)

## Method (gh only)

1. Read config and determine mode:
   - targeted (`target.type` + `target.number`)
   - exploratory (open issues/PRs)
2. Fetch with gh CLI commands equivalent to:
   - `gh issue view <n> --json ...`
   - `gh pr view <n> --json ...`
   - `gh issue list --state open --limit 10 --json ...`
   - `gh pr list --state open --limit 5 --json ...`
3. Write `.cursor/work/github-signals.md` with:
   - timestamp
   - retrieval method: `gh`
   - facts-only issues and PRs

## Constraints

- Do not add analysis or recommendations.
- Keep output format stable and concise.
