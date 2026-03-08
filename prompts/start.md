# Start Prompt

## Purpose

Start an AIDD cycle in either:
- **Targeted mode** (specific GitHub issue/PR)
- **Exploratory mode** (repo scan without a specific target)

GitHub signals are fetched with `gh-context.sh` only.
Context7 is mandatory before implementation when external libraries are involved.

## Procedure

### 1) Select mode

Ask user:
- `A` Targeted (Issue/PR)
- `B` Exploratory

### 2A) Targeted mode (Issue/PR)

1. Ask for:
   - repository (`owner/name`)
   - type (`issue` or `pr`)
   - number
2. Write/update `aidd/work/github-signals.config.yml` with this target.
3. Create/update `aidd/work/TARGET.md`.
4. Fetch GitHub facts via `bash scripts/gh-context.sh`:
   - `issue <number>` or `pr <number>`
   - optional: `issues-open` / `prs-open` for context
5. Write `aidd/work/github-signals.md` (facts only):
   - IDs, titles, labels, state
   - retrieval method: `gh-context.sh`
6. Update `aidd/work/RUN_STATE.json` with current target identity.

### 2B) Exploratory mode

1. Optionally ask for repository owner/name if needed.
2. Fetch lightweight signals with:
   - `bash scripts/gh-context.sh issues-open`
   - `bash scripts/gh-context.sh prs-open`
3. Write `aidd/work/github-signals.md` (facts only, no interpretation).

### 3) Continue standard flow

1. Run `prompts/audit.md` → update `aidd/work/AUDIT.md`
2. Run `prompts/intake.md` → update `aidd/work/INTAKE.md`
3. Run `prompts/plan.md` → update `aidd/work/PLAN.md`
4. Run gate: `bash scripts/validate-plan.sh`

## Mandatory constraints

- Use `gh-context.sh` only for GitHub signals.
- Keep signals factual (no recommendations in `github-signals.md`).
- Track concise progress in `aidd/work/SUMMARY.md`.
- Use `CONTEXT_BUDGET` (`low|medium|high`) with default `low`.

## Context7 reminder (hard gate downstream)

Before implementing code that depends on external libs/APIs, run:

```bash
bash scripts/c7-docs.sh --library <library-id> [--topic <topic>] [--tokens <n>]
```

This command records Context7 evidence in `aidd/work/SUMMARY.md`.
`bash scripts/aidd-check.sh` will fail if Context7 evidence is missing.
