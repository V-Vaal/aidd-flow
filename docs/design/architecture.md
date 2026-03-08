# Framework Architecture

Architecture decisions and export model for `aidd-flow`.

## Directory Structure (source repository)

```
aidd-flow/
├── AGENTS.md                   # Source-repo entry point
├── .env.example                # Optional env defaults (CONTEXT_BUDGET, cache TTL)
├── aidd/
│   ├── memory/
│   ├── work/
│   └── review/
├── rules/
├── prompts/
├── scripts/
└── docs/
    └── templates/AGENTS.root.md  # Exported root AGENTS template
```

## Export Model

`bash scripts/aidd-export.sh <target-project>` installs the workflow into:

- `<target>/.aidd-flow/` (engine)
- `<target>/AGENTS.md` (single root entry point)

Important guarantees:

- `AGENTS.md` is created at target root from `docs/templates/AGENTS.root.md`
- `.aidd-flow/AGENTS.md` is not exported
- Existing `AGENTS.md` is protected by `--force-agents` / `--backup-agents`

## Design Decisions

### 1) Single project entry point

Each target project must expose exactly one entry point:
- `<target>/AGENTS.md`

### 2) Engine isolation

All workflow internals stay under `.aidd-flow/` in target projects.

### 3) GitHub signals via gh

GitHub external signals are collected with `gh-context.sh` only.
No legacy GitHub adapter dependency is used.

### 4) Context7 mandatory for external libs

`c7-docs.sh` is required before implementation involving external library APIs.
`aidd-check.sh` enforces evidence in `aidd/work/SUMMARY.md`.

### 5) Token-efficient artefacts

Short-lived high-signal artefacts:
- `aidd/work/SUMMARY.md`
- `aidd/work/HANDOFF.md`
- `aidd/work/DIFF_DIGEST.md`
- `aidd/work/RULES_JIT.md`

`CONTEXT_BUDGET` controls context size (`low|medium|high`, default `low`).
