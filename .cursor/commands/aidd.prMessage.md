# AIDD PR Message Command

## Purpose

Generate a commit message and PR description based on the AIDD workflow artifacts (INTAKE, PLAN, REVIEW, activeContext). This command helps create consistent, well-documented PR messages that reference the AIDD workflow.

## Usage

1. **Read the canonical prompt**: Open and follow `.cursor/prompts/pr-message.md`
2. **Produce the artifact**: Create or update `.cursor/work/PR.md` following the prompt's procedure

## Quick Reference

- **Prompt**: `.cursor/prompts/pr-message.md`
- **Output**: `.cursor/work/PR.md`

## Master Workflow Reminder

- PR should only be created if REVIEW.md Verdict is APPROVE
- Ensure all workflow gates have passed:
  - PLAN.md validated
  - Tests pass
  - Review approved
  - activeContext.md updated
- Follow `.cursor/rules/05-workflows-and-processes/5-open-source-pr.mdc` for PR format if present
- Include security checklist if applicable

