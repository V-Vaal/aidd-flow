# AGENTS.md — project

Entry point for any AI agent: OpenCode, Claude Code, Cursor, GitHub Copilot, or any LLM-based tool.
Load this file first.

This project uses aidd-flow installed under `.aidd-flow/`.
All workflow commands and artefacts below use `.aidd-flow/*` paths.

---

## Framework Structure

```
.aidd-flow/aidd/memory/        # Persistent project context — read at session start
.aidd-flow/aidd/work/          # Runtime artifacts — AUDIT, INTAKE, PLAN, REVIEW, SUMMARY, HANDOFF
.aidd-flow/aidd/review/        # Domain review checklists (web3, ml, general)
.aidd-flow/rules/              # Plain Markdown rules
.aidd-flow/rules/INDEX.md      # Rules catalog
.aidd-flow/prompts/            # Workflow prompts
.aidd-flow/scripts/            # Validation and utility scripts
```

---

## Operating Modes

### ARCHITECT MODE — Think and Plan

1. Read `.aidd-flow/aidd/memory/activeContext.md` and `.aidd-flow/aidd/memory/projectbrief.md`
2. Run audit if repository is non-trivial and no `.aidd-flow/aidd/work/AUDIT.md` exists
3. Capture requirements into `.aidd-flow/aidd/work/INTAKE.md`
4. Produce technical plan into `.aidd-flow/aidd/work/PLAN.md`
5. Run gate: `bash .aidd-flow/scripts/validate-plan.sh`

### EDITOR MODE — Execute Under Constraints

1. Load always-apply rules from `.aidd-flow/rules/INDEX.md`
2. Load only stack/task-relevant rules (just-in-time loading)
3. Use `bash .aidd-flow/scripts/c7-docs.sh ...` before coding against external libraries
4. Implement exactly what `.aidd-flow/aidd/work/PLAN.md` defines
5. Run gate: `bash .aidd-flow/scripts/aidd-check.sh`
6. If UI changed: `bash .aidd-flow/scripts/aidd-verify-ui.sh`
7. Update `.aidd-flow/aidd/memory/activeContext.md`

### REVIEWER MODE — Human Audit Required

1. Select checklist by domain:
   - web3 → `review-checklist-web3.md`
   - ml → `review-checklist-ml.md`
   - mixed → both
   - other / unknown → `review-checklist-general.md`
2. Produce review into `.aidd-flow/aidd/work/REVIEW.md`
3. Run gate: `bash .aidd-flow/scripts/review-check.sh`
4. Optional closeout: `bash .aidd-flow/scripts/aidd-finish.sh`

---

## Mandatory Gates

- `bash .aidd-flow/scripts/validate-plan.sh` (blocks implementation)
- `bash .aidd-flow/scripts/aidd-check.sh` (blocks review)
- `bash .aidd-flow/scripts/review-check.sh` (blocks done state)

Definition of done:
- PLAN validated
- Implementation complete
- activeContext updated
- REVIEW verdict is `APPROVE`

---

## External Signals and Docs

- GitHub signals: use `bash .aidd-flow/scripts/gh-context.sh ...` (JSON output).
- Context7 docs: use `bash .aidd-flow/scripts/c7-docs.sh --library <id> [--topic <topic>]`.
- Context7 is mandatory and enforced by `aidd-check.sh`.

---

## Token Efficiency

- Use `rtk` wrappers whenever supported.
- Use `CONTEXT_BUDGET` (`low|medium|high`, default `low`) to control context loading.
- Prefer concise summaries:
  - `.aidd-flow/aidd/work/SUMMARY.md` for in-cycle digest
  - `.aidd-flow/aidd/work/HANDOFF.md` for end-of-cycle transfer
- Keep responses findings-first and avoid repeating unchanged context.
