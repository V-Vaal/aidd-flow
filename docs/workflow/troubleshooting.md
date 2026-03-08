# Troubleshooting

## Scripts don't work

```bash
chmod +x scripts/*.sh
```

## Rules not detected

```bash
bash scripts/validate-rules.sh
```

## Path errors

Run scripts from project root.

## gh CLI not authenticated

```bash
gh auth login
```

## GitHub signals missing

- Ensure `gh` is installed and authenticated.
- Rerun:
  - `bash scripts/gh-context.sh issues-open`
  - `bash scripts/gh-context.sh prs-open`
- Regenerate `aidd/work/github-signals.md`.

## Context7 command fails

Possible causes:
- Invalid `--library` id
- Network timeout
- Malformed `--topic`

Retry with explicit parameters:

```bash
bash scripts/c7-docs.sh --library reactjs/react.dev --topic hooks --tokens 2000
```

## aidd-check fails on Context7 evidence

`aidd-check.sh` requires at least one entry in `aidd/work/SUMMARY.md` under `## Context7 Evidence`.

Fix:
1. Run `bash scripts/c7-docs.sh --library <id> [--topic <topic>]`
2. Verify evidence was appended to `aidd/work/SUMMARY.md`
3. Rerun `bash scripts/aidd-check.sh`

## Context is too large

- Set `CONTEXT_BUDGET=low`
- Run `bash scripts/aidd-context.sh`
- Prefer `aidd/work/SUMMARY.md` + `aidd/work/HANDOFF.md`

## Diff review is noisy

Generate compact digest:

```bash
bash scripts/aidd-diff-digest.sh
```

Use `aidd/work/DIFF_DIGEST.md` instead of raw full diff when possible.
