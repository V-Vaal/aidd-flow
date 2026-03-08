# GitHub Signals

External signals collection for AUDIT using `gh-context.sh` (gh CLI), facts-only.

## Rule

- Collect signals through `bash scripts/gh-context.sh ...`.
- Store facts in `aidd/work/github-signals.md` with no interpretation.

## Supported commands

```bash
bash scripts/gh-context.sh issues-open
bash scripts/gh-context.sh prs-open
bash scripts/gh-context.sh issue <NUMBER>
bash scripts/gh-context.sh pr <NUMBER>
```

## Required output format

`aidd/work/github-signals.md` must include:

- Retrieval method: `gh-context.sh`
- Timestamp (UTC)
- Issues section (id, title, labels, state)
- Pull requests section (id, title, labels/state)

Example line:

```markdown
- #123: "Fix authentication bug" [bug,security] open
```

## Targeted mode notes

When target mode is used:

- Keep target metadata in `aidd/work/TARGET.md`
- Keep query configuration in `aidd/work/github-signals.config.yml`
- Keep state in `aidd/work/RUN_STATE.json`
- If target identity changes, archive old target artefacts before writing new ones

## Failure handling

If GitHub retrieval fails:

- Keep the workflow running
- Record failure factually in `github-signals.md`
- Continue with local repository audit

## Integration with AUDIT

`prompts/audit.md` reads `github-signals.md` and copies facts into:

- `## External Signals (GitHub)`

No prioritization or recommendations are allowed in that section.
