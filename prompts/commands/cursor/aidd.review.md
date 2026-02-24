<!-- CURSOR-SPECIFIC: This file uses Cursor slash command syntax (@command).
     For IDE-agnostic equivalents, use the corresponding file in prompts/.
     Reference: prompts/start.md, prompts/intake.md, prompts/plan.md, etc. -->
# AIDD Review Command

## Purpose

Create or update the REVIEW.md artifact with code review findings, test evidence, risk assessment, and a formal verdict. This is the review phase in the AIDD workflow (Reviewer role), required before marking work as complete.

## Usage

1. **Read the canonical prompt**: Open and follow `.cursor/prompts/review.md`
2. **Produce the artifact**: Create or update `.cursor/work/REVIEW.md` following the prompt's procedure
3. **Run validation**: Execute `bash .cursor/scripts/review-check.sh` to validate REVIEW.md

## Quick Reference

- **Prompt**: `.cursor/prompts/review.md`
- **Output**: `.cursor/work/REVIEW.md`
- **Validation**: `bash .cursor/scripts/review-check.sh`

## Master Workflow Reminder

- Review is **MANDATORY** before marking work as done
- Verdict field is required and must be APPROVE or CHANGES_REQUESTED
- Work is **NOT DONE** until Verdict is APPROVE
- After review approval, update `.cursor/memory/activeContext.md` with completion details
