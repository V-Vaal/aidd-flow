<!-- CURSOR-SPECIFIC: This file uses Cursor slash command syntax (@command).
     For IDE-agnostic equivalents, use the corresponding file in prompts/.
     Reference: prompts/start.md, prompts/intake.md, prompts/plan.md, etc. -->
# AIDD Validate Command

## Purpose

Run the plan validation gate to ensure PLAN.md is valid before proceeding with implementation. This command enforces the pre-flight check required by the master workflow rule.

## Usage

1. **Run validation script**: Execute `bash .cursor/scripts/validate-plan.sh`
2. **Interpret results**:
   - If validation passes (exit code 0): PLAN.md is valid, proceed with implementation
   - If validation fails (exit code 1): **DO NOT PROCEED**, fix PLAN.md and re-run validation

## Quick Reference

- **Script**: `bash .cursor/scripts/validate-plan.sh`
- **Validates**: `.cursor/work/PLAN.md`

## Master Workflow Reminder

- This validation is **MANDATORY** before any implementation work
- The master workflow rule requires PLAN.md validation to pass
- Never proceed with implementation if validation fails
- After successful modifications, update `.cursor/memory/activeContext.md`
- Review is mandatory: create REVIEW.md with Verdict (APPROVE | CHANGES_REQUESTED)
