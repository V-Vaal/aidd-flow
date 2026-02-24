# AGENTS.md — aidd-flow

Entry point for any AI agent: OpenCode, Claude Code, Cursor, GitHub Copilot, or any LLM-based tool.
Load this file first. Follow the mode that matches your current task.

---

## Framework Structure

```
aidd/memory/        # Persistent project context — read at session start
aidd/work/          # Runtime artifacts — AUDIT, INTAKE, PLAN, REVIEW (gitignored)
aidd/review/        # Domain-specific review checklists (web3, ml)
rules/              # Plain Markdown rules — load relevant files per stack
rules/INDEX.md      # Rules catalog with always-apply and deprecated flags
prompts/            # Workflow prompts — use as instructions per phase
scripts/            # Validation gate scripts — mandatory checkpoints
docs/workflow/README.md    # Complete workflow reference
docs/design/architecture.md  # MCP setup, export guide, ADRs
```

---

## Operating Modes

### ARCHITECT MODE — Think and Plan

**When:** Starting a new task, feature, or fix. Before writing any code.

**Steps:**
1. Read `aidd/memory/activeContext.md` and `aidd/memory/projectbrief.md`
2. Run audit if repository is non-trivial and no `aidd/work/AUDIT.md` exists — use `prompts/audit.md`
3. Capture requirements using `prompts/intake.md` → produces `aidd/work/INTAKE.md`
4. Produce technical plan using `prompts/plan.md` → produces `aidd/work/PLAN.md`
5. **Gate:** `bash scripts/validate-plan.sh` — do not proceed if it fails

**Rules:** Never implement before `validate-plan.sh` passes. Never guess unproven facts — document assumptions in INTAKE Open Questions.

---

### EDITOR MODE — Execute Under Constraints

**When:** `aidd/work/PLAN.md` exists and has passed `validate-plan.sh`.

**Steps:**
1. Load always-apply rules from `rules/INDEX.md` into context
2. Load stack-specific rules relevant to the task (TypeScript, React, Solidity, etc.)
3. Read `aidd/memory/` files for project-specific patterns and conventions
4. Implement following `aidd/work/PLAN.md` steps exactly — no scope creep
5. After implementation: `bash scripts/aidd-check.sh`
6. If UI changes: `bash scripts/aidd-verify-ui.sh`
7. Update `aidd/memory/activeContext.md` with what was completed and next steps

**Rules:** Follow the plan. Do not invent new dependencies or patterns not referenced in `rules/` or `aidd/memory/`. Use `rtk` for all shell operations (see Token Efficiency below).

---

### REVIEWER MODE — Human Audit Required

**When:** Implementation is complete and `aidd-check.sh` passes.

**Steps:**
1. Load domain checklist from `aidd/review/` if applicable
2. Produce review using `prompts/review.md` → produces `aidd/work/REVIEW.md`
3. **Gate:** `bash scripts/review-check.sh` — task is not done until Verdict is `APPROVE`
4. Optional closeout: `bash scripts/aidd-finish.sh` (guided commit/push/PR + cleanup)
5. Verdict must be one of: `APPROVE` or `CHANGES_REQUESTED`
6. If `CHANGES_REQUESTED`: return to EDITOR MODE with specific change requests

**Rules:** No change is considered done without a human-reviewed `APPROVE` verdict. The reviewer role requires human judgment — do not auto-approve.

---

## Mandatory Gates

| Gate | Script | Blocks |
|------|--------|--------|
| Plan validation | `bash scripts/validate-plan.sh` | Implementation (ARCHITECT → EDITOR) |
| Implementation check | `bash scripts/aidd-check.sh` | Review (EDITOR → REVIEWER) |
| Review verdict | `bash scripts/review-check.sh` | Done (REVIEWER → complete) |

**Definition of Done:** PLAN.md validated + implementation complete + `aidd/memory/activeContext.md` updated + REVIEW.md verdict is `APPROVE`.

---

## Token Efficiency (RTK)

Use `rtk` wrappers for all shell operations to minimize output tokens:

```bash
rtk git status        # instead of: git status
rtk git diff          # instead of: git diff
rtk git log           # instead of: git log
rtk grep <pattern>    # instead of: rg / grep
rtk ls                # instead of: ls -la
rtk test <cmd>        # instead of: running test commands directly
```

Fall back to raw commands only if `rtk` does not support the operation.

---

## MCP Obsidian (Knowledge Vault)

Use `obsidian_alyra_*` tools **only** when the task involves complex or ambiguous blockchain / AI concepts requiring confirmation of definitions, formulas, or nuanced technical details.

Protocol:
1. `obsidian_alyra_search_notes` — short query, limit 3–5 results
2. `obsidian_alyra_read_note` — read at most 1 note (the most relevant)
3. Summarize findings in your own words — do not paste large note blocks

Never use MCP Obsidian for general coding tasks. Never attempt to write to the vault.

---

## MCP GitHub

Used during the Architect phase (GitHub signals step in `prompts/start.md`) to fetch facts-only data from GitHub issues and PRs.

Requires `GITHUB_TOKEN` environment variable. See `mcp.example.json` for server configuration and `docs/design/architecture.md` for IDE-specific setup instructions.
