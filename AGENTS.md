# AGENTS.md — aidd-flow

Entry point for any AI agent: OpenCode, Claude Code, Cursor, GitHub Copilot, or any LLM-based tool.
Load this file first. Follow the mode that matches your current task.

---

## Framework Structure

```
aidd/memory/        # Persistent project context — read at session start
aidd/work/          # Runtime artifacts — AUDIT, INTAKE, PLAN, REVIEW, SUMMARY, HANDOFF
aidd/review/        # Domain-specific review checklists (web3, ml, general)
rules/              # Plain Markdown rules — load relevant files per stack
rules/INDEX.md      # Rules catalog with always-apply and deprecated flags
prompts/            # Workflow prompts — use as instructions per phase
scripts/            # Validation gate scripts — mandatory checkpoints
docs/workflow/README.md    # Complete workflow reference
docs/design/architecture.md  # Export guide, architecture decisions
```

---

## Operating Modes

### ARCHITECT MODE — Think and Plan

**When:** Starting a new task, feature, or fix. Before writing any code.

**Steps:**
1. Read `aidd/memory/activeContext.md` and `aidd/memory/projectbrief.md`
2. Run audit if repository is non-trivial and no `aidd/work/AUDIT.md` exists
3. Capture requirements using `prompts/intake.md` → produces `aidd/work/INTAKE.md`
4. Produce technical plan using `prompts/plan.md` → produces `aidd/work/PLAN.md`
5. **Gate:** `bash scripts/validate-plan.sh` — do not proceed if it fails

### EDITOR MODE — Execute Under Constraints

**When:** `aidd/work/PLAN.md` exists and has passed `validate-plan.sh`.

**Steps:**
1. Load always-apply rules from `rules/INDEX.md`
2. Load only stack/task-relevant rules (just-in-time loading)
3. Use `bash scripts/c7-docs.sh ...` before coding against external libraries
4. Implement following `aidd/work/PLAN.md` steps exactly — no scope creep
5. Run: `bash scripts/aidd-check.sh`
6. If UI changes: `bash scripts/aidd-verify-ui.sh`
7. Update `aidd/memory/activeContext.md` with completed work and next steps

### REVIEWER MODE — Human Audit Required

**When:** Implementation is complete and `aidd-check.sh` passes.

**Steps:**
1. Load checklist based on domain:
   - `web3` → `aidd/review/review-checklist-web3.md`
   - `ml` → `aidd/review/review-checklist-ml.md`
   - `mixed` → both checklists
   - `other` or unknown → `aidd/review/review-checklist-general.md`
2. Produce review using `prompts/review.md` → `aidd/work/REVIEW.md`
3. **Gate:** `bash scripts/review-check.sh` — task is not done until Verdict is `APPROVE`
4. Optional closeout: `bash scripts/aidd-finish.sh` (guided commit/push/PR + cleanup + handoff)

---

## Mandatory Gates

| Gate | Script | Blocks |
|------|--------|--------|
| Plan validation | `bash scripts/validate-plan.sh` | Implementation (ARCHITECT → EDITOR) |
| Implementation check | `bash scripts/aidd-check.sh` | Review (EDITOR → REVIEWER) |
| Review verdict | `bash scripts/review-check.sh` | Done (REVIEWER → complete) |

**Definition of Done:** PLAN validated + implementation complete + `activeContext.md` updated + REVIEW verdict is `APPROVE`.

---

## External Signals and Docs

- GitHub signals: use `bash scripts/gh-context.sh ...` (JSON output)
- Library docs: use `bash scripts/c7-docs.sh --library <id> [--topic <topic>]`
- Context7 usage is mandatory and enforced by `aidd-check.sh`

---

## Token Efficiency

- Use `rtk` wrappers for shell operations when supported.
- Use `CONTEXT_BUDGET` (`low|medium|high`, default `low`) to control context loading.
- Keep `aidd/work/SUMMARY.md` updated as the short in-cycle digest.
- Generate `aidd/work/HANDOFF.md` at cycle closeout for fast restart.
- Prefer findings-first concise outputs; avoid repeating unchanged context.

---

## MCP Obsidian (Knowledge Vault)

Use `obsidian_alyra_*` tools only for complex or ambiguous blockchain / AI concepts requiring confirmation of definitions, formulas, or nuanced technical details.

Protocol:
1. `obsidian_alyra_search_notes` — short query, limit 3–5 results
2. `obsidian_alyra_read_note` — read at most 1 note (the most relevant)
3. Summarize findings in your own words — do not paste large note blocks

Never use MCP Obsidian for general coding tasks. Never attempt to write to the vault.
