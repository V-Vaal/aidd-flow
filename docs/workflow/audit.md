# Audit Phase

Audit-first practices for establishing evidence, risks, and initial findings before planning.

## Audit-first in Practice

**When to do an AUDIT:**
- New repository or unfamiliar codebase
- Uncertain architecture or dependencies
- Risky changes (security, data migration, breaking changes)
- Large refactors or multi-file changes
- Security-sensitive features

**When NOT to do an AUDIT:**
- Tiny changes (single file, typo fix)
- Trivial repositories (single script, simple config)
- Purely mechanical edits (formatting, renaming)
- Documentation-only changes

**AUDIT outputs:**
- Repository scope and structure
- Risk hotspots and sensitive areas
- Assumptions about current state
- Quick wins and recommendations
- Open questions

**AUDIT → PLAN handoff:**
- Use AUDIT findings to inform INTAKE constraints
- Reference AUDIT risks in PLAN risk assessment
- Use AUDIT architecture insights for PLAN file selection
- Address AUDIT open questions in PLAN notes

## External Signals (GitHub)

When a GitHub repository exists, AUDIT must include external signals from issues and PRs using a facts-only format.
See the full specification in [GitHub Signals](github-signals.md).
