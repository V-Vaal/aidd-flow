<!-- CURSOR-SPECIFIC: This file uses Cursor slash command syntax (@command).
     For IDE-agnostic equivalents, use the corresponding file in prompts/.
     Reference: prompts/start.md, prompts/intake.md, prompts/plan.md, etc. -->
# AIDD Start Command

## Purpose

Single entrypoint command to initiate AIDD workflow in two modes:
- **Targeted (Issue/PR)**: Fetch GitHub signals for a specific issue or PR, then run full workflow
- **Exploratory (Repo scan)**: Run repository audit to produce findings without GitHub MCP requirement

## Usage

1. **Read the canonical prompt**: Open and follow `.cursor/prompts/start.md`
2. **Follow interactive flow**: Prompt guides mode selection and execution sequence
3. **Produce artifacts**: Creates work artifacts based on selected mode

**Note:** This is an operator checklist/orchestration guide; it does not execute scripts automatically.

## Quick Reference

- **Prompt**: `.cursor/prompts/start.md`
- **Mode A (Targeted)**: Requires GitHub MCP, produces github-signals.md → AUDIT.md → INTAKE.md → PLAN.md
- **Mode B (Exploratory)**: No GitHub MCP required, produces AUDIT.md with findings
- **Reset Gate**: Automatically archives previous artifacts when target changes (see `docs/workflow/github-signals.md#target-reset-gate`)

## Master Workflow Reminder

- **Targeted mode**: Full workflow with validation gates (validate-intake.sh)
- **Exploratory mode**: Audit-only, findings can be converted to Targeted runs later
- After completion, proceed to UI ChatGPT for architect validation (AUDIT/INTAKE/PLAN)
- Review is mandatory: create REVIEW.md with Verdict (APPROVE | CHANGES_REQUESTED)
