# Workflow Overview

Complete workflow lifecycle for executing AI-assisted development tasks with structured gates, checkpoints, and auditability.

## Workflow at a Glance

1. **AUDIT** → Understand codebase (if needed)
2. **INTAKE** → Capture requirements and constraints
3. **PLAN** → Technical plan with steps, tests, rollback
4. **IMPLEMENT** → Code following PLAN.md
5. **VERIFY** → Run gates (validate-plan.sh, aidd-check.sh)
6. **REVIEW** → Code review with Verdict (APPROVE | CHANGES_REQUESTED)
7. **UPDATE CONTEXT** → Update activeContext.md with completion

## Workflow Steps

**0. Audit** (when repository is non-trivial and no AUDIT.md exists)
- Prompt: `prompts/audit.md` or `prompts/start.md` (exploratory mode)
- Creates: `aidd/work/AUDIT.md`
- Use findings to inform planning

**1. Intake**
- Prompt: `prompts/intake.md`
- Creates: `aidd/work/INTAKE.md`
- Define goal, scope, constraints, risks, acceptance criteria
- See [INTAKE specification](../quality/intake.md) for structure

**2. Plan**
- Prompt: `prompts/plan.md`
- Creates: `aidd/work/PLAN.md`
- Document steps, files to touch, tests, rollback strategy
- See [PLAN specification](../quality/technical-plan.md) for structure

**3. Validate Plan**
- Prompt: `bash scripts/validate-plan.sh`
- **Gate**: Do not proceed if validation fails

**4. Implement**
- Use your AI agent
- Follow rules in `rules/`
- Reference PLAN.md steps

**5. Checks**
- `bash scripts/aidd-check.sh`
- `bash scripts/aidd-verify-ui.sh` (if UI changes)

**6. Review**
- Prompt: `prompts/review.md`
- Creates: `aidd/work/REVIEW.md` with Verdict (APPROVE | CHANGES_REQUESTED)
- Validate: `bash scripts/review-check.sh`
- **Gate**: Task not done until Verdict is APPROVE

**7. Update Active Context**
- Prompt: Update `aidd/memory/activeContext.md`
- Updates: `aidd/memory/activeContext.md`
- Document what was completed, current state, next steps
