<!-- CURSOR-SPECIFIC: This file uses Cursor slash command syntax (@command).
     For IDE-agnostic equivalents, use the corresponding file in prompts/.
     Reference: prompts/start.md, prompts/intake.md, prompts/plan.md, etc. -->
# AIDD Intake Command

## Purpose

Create or update the INTAKE.md artifact to capture requirements, constraints, assumptions, risks, and acceptance criteria for a new feature or task. This is the first step in the AIDD workflow (Architect role).

## Usage

1. **Read the canonical prompt**: Open and follow `.cursor/prompts/intake.md`
2. **Produce the artifact**: Create or update `.cursor/work/INTAKE.md` following the prompt's procedure

## Quick Reference

- **Prompt**: `.cursor/prompts/intake.md`
- **Output**: `.cursor/work/INTAKE.md`

## Master Workflow Reminder

- After INTAKE is complete, proceed to PLAN creation
- The PLAN must be validated with `bash .cursor/scripts/validate-plan.sh` before implementation
- After successful modifications, update `.cursor/memory/activeContext.md`
- Review is mandatory: create REVIEW.md with Verdict (APPROVE | CHANGES_REQUESTED)
