# Cursor Command (Archived) — aidd.start

Start AIDD workflow in one of two modes:

- **Mode A (Targeted)**: issue/pr focused, requires gh-authenticated access
- **Mode B (Exploratory)**: repository scan without explicit target

## Mode A output chain

`github-signals.md -> AUDIT.md -> INTAKE.md -> PLAN.md`

## Mode B output chain

`AUDIT.md -> INTAKE.md -> PLAN.md`

## Rules

- GitHub signals are collected with gh only.
- No additional GitHub integration dependency.
- Facts-only in `github-signals.md`.
