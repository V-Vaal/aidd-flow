# AIDD Plan Command

## Purpose

Create or update the PLAN.md artifact with a detailed technical plan including architecture, steps, files to modify, tests, and rollback strategy. This is the second step in the AIDD workflow (Editor role), following INTAKE approval.

## Usage

1. **Read the canonical prompt**: Open and follow `.cursor/prompts/plan.md`
2. **Produce the artifact**: Create or update `.cursor/work/PLAN.md` following the prompt's procedure
3. **Validate the plan**: Run `bash .cursor/scripts/validate-plan.sh` before proceeding

## Quick Reference

- **Prompt**: `.cursor/prompts/plan.md`
- **Output**: `.cursor/work/PLAN.md`
- **Validation**: `bash .cursor/scripts/validate-plan.sh`

## Master Workflow Reminder

- **CRITICAL**: Before implementation, run `bash .cursor/scripts/validate-plan.sh` to ensure PLAN.md is valid
- **DO NOT PROCEED** with implementation if PLAN.md validation fails
- After successful modifications, update `.cursor/memory/activeContext.md`
- Review is mandatory: create REVIEW.md with Verdict (APPROVE | CHANGES_REQUESTED)
- No task is DONE without review approval (Verdict: APPROVE)

