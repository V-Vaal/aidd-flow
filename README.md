> 🇬🇧 English (default) | 🇫🇷 [Version française](README.fr.md)

# aidd-flow

An IDE-agnostic, industrial-grade implementation of an AI-Driven Development (AIDD) workflow focused on orchestration, checkpoints, and auditability. Works with OpenCode, Claude Code, Cursor, GitHub Copilot, or any LLM-based agent.

---

## What is AI-Driven Development (AIDD)?

AI-Driven Development is a development workflow and decision-making process where AI assists human judgment rather than operating autonomously. In AIDD:

- **AI is an assistant**, not an autonomous agent
- **Humans make decisions** at critical checkpoints
- **AI executes** under explicit constraints and rules
- **Work is auditable** through structured artifacts and traceable decisions

AIDD emphasizes method over automation: clear rules, explicit plans, automated checks, and mandatory human review before accepting changes.

---

## What is aidd-flow?

`aidd-flow` is a practical, IDE-agnostic implementation of an AIDD workflow built on a **tripartite role pattern**:

- **Architect** — thinks and plans before any code is written
- **Editor** — executes under constraints defined by the plan and rules
- **Reviewer** — performs a mandatory human audit before marking work done

This repository provides:

- **Orchestration**: A single `AGENTS.md` entry point loaded automatically by any agent
- **Checkpoints**: Validation gate scripts enforcing plan quality and review verdicts
- **Auditability**: Persistent artifacts (AUDIT, INTAKE, PLAN, REVIEW) documenting decisions
- **Rules library**: 30+ plain Markdown rules covering clean code, security, languages, frameworks, QA
- **Memory bank**: Persistent context files (`projectbrief`, `techContext`, `systemPatterns`, `activeContext`)

---

## Scope

### What this repository helps with

- **Structured AI-assisted development**: From issue/PR to reviewed implementation
- **Decision traceability**: Clear artifacts documenting what was decided and why
- **Quality gates**: Automated validation of plans and mandatory human review
- **Project continuity**: Memory bank and active context for multi-session work
- **IDE-agnostic workflows**: Works with OpenCode, Claude Code, Cursor, Copilot, and others

### What this repository does not attempt to solve

- **Universal methodology**: This is a practical workflow, not a theoretical framework
- **Team collaboration**: Designed for individual or small team use, not enterprise-scale processes
- **Certification or training**: No official certification or training program

---

## Installation

### Option 1: Clone and use directly

```bash
git clone https://github.com/V-Vaal/aidd-flow.git
cd aidd-flow
```

Fill in `aidd/memory/` files for your project context, then start the workflow via `AGENTS.md`.

### Option 2: Export to an existing project

```bash
git clone https://github.com/V-Vaal/aidd-flow.git
cd aidd-flow

bash scripts/aidd-export.sh /path/to/your/target-project
```

This exports the full workflow into `/path/to/your/target-project/.aidd-flow/`, creates a root `AGENTS.md` redirect, and writes `.aidd-flow/aidd/aidd.lock` for version tracking.

Safety behavior:
- If `.aidd-flow/` exists and is non-empty, the script refuses unless you pass `--force` or `--backup`.
- If `AGENTS.md` already exists at the target root, the script refuses unless you pass `--force-agents` or `--backup-agents`.

After export, configure the GitHub MCP server for your IDE — see `mcp.example.json` and `docs/design/architecture.md`.

---

## Quickstart

`AGENTS.md` is the universal entry point. It is loaded automatically by OpenCode and Claude Code. The `prompts/commands/cursor/` folder is a historical archive you can use as inspiration to recreate Cursor slash commands.

### Prerequisites

- Any AI agent (OpenCode, Claude Code, Cursor agent mode, GitHub Copilot Chat, ...)
- Git repository with the workflow installed (see [Installation](#installation))
- (Optional) GitHub MCP server for targeted mode — see `mcp.example.json`

### The three-phase workflow

**Phase 1 — Architect** (plan before you build)

1. Read `aidd/memory/activeContext.md` and `aidd/memory/projectbrief.md`
2. Load `prompts/intake.md` → produces `aidd/work/INTAKE.md`
3. Load `prompts/plan.md` → produces `aidd/work/PLAN.md`
4. Run gate: `bash scripts/validate-plan.sh` — do not proceed if it fails

**Phase 2 — Editor** (build under constraints)

5. Load relevant rules from `rules/` (see `rules/INDEX.md` for always-apply rules)
6. Implement following `aidd/work/PLAN.md` exactly
7. Run: `bash scripts/aidd-check.sh`

**Phase 3 — Reviewer** (human audit mandatory)

8. Load `prompts/review.md` → produces `aidd/work/REVIEW.md`
9. Run gate: `bash scripts/review-check.sh` — task is not done until Verdict is `APPROVE`

### IDE-specific shortcuts

| Agent | Entry point |
|-------|-------------|
| OpenCode / Claude Code | `AGENTS.md` loaded automatically at session start |
| Cursor | Historical archive in `prompts/commands/cursor/` (not plug-and-play) |
| Other agents | Copy the relevant `prompts/*.md` content into your chat context |

---

## Core design principles

> If you want better code, improve the system, not the model.

This workflow does not attempt to "make AI smarter". It focuses on improving the conditions under which code is produced: clear constraints, explicit plans, validation gates, and human review.

### Human in-the-loop decision points

Critical decisions require human judgment:
- **Intake validation**: Human reviews and approves requirements
- **Plan approval**: Human validates technical approach before implementation
- **Review verdict**: Human provides formal approval (`APPROVE` | `CHANGES_REQUESTED`)

### Clear role separation

- **Human as orchestrator**: Sets rules, validates plans, makes decisions, provides verdicts
- **AI as executor**: Implements plans under constraints, follows rules, generates artifacts

### Auditability and traceability

All AI-assisted work produces structured artifacts in `aidd/work/`:
- `AUDIT.md`: Repository state and findings
- `INTAKE.md`: Requirements, constraints, acceptance criteria
- `PLAN.md`: Technical steps, files to touch, rollback plan
- `REVIEW.md`: Review summary, test evidence, formal verdict

These artifacts document **what was decided**, **why it was decided**, and **what evidence supports the decision**.

---

## Repository structure

```
aidd-flow/
├── AGENTS.md                  # Universal agent entry point (3 modes + gates + RTK)
├── mcp.example.json           # MCP GitHub server template
├── .env.example               # Required environment variables
│
├── aidd/
│   ├── memory/                # Persistent context — fill once per project
│   ├── work/                  # Runtime artifacts — gitignored (AUDIT, INTAKE, PLAN, REVIEW)
│   └── review/                # Domain-specific review checklists (web3, ml)
│
├── rules/                     # 30+ plain Markdown rules
│   └── INDEX.md               # Rules catalog (always-apply, stack-specific, deprecated)
│
├── prompts/                   # Workflow prompts (start, intake, plan, audit, review, ...)
│   └── commands/cursor/       # Cursor slash commands (archived reference)
│
├── scripts/                   # Validation gate scripts
│   ├── validate-plan.sh       # Gate: blocks implementation if PLAN.md is invalid
│   ├── review-check.sh        # Gate: blocks completion if REVIEW.md is not APPROVE
│   ├── aidd-check.sh          # Post-implementation checks
│   ├── aidd-export.sh         # Export framework to a target project
│   └── aidd-cleanup.sh        # Archive aidd/work/ artifacts older than 30 days
│
└── docs/
    ├── workflow.md             # Complete workflow reference
    ├── design/architecture.md  # MCP setup, export guide, framework ADRs
    └── quality/               # Artifact specifications (intake, technical-plan)
```

---

## Documentation

- [Workflow guide](docs/workflow/README.md): Complete workflow method with gates, governance, and troubleshooting
- [Architecture guide](docs/design/architecture.md): MCP setup per IDE, export guide, design decisions
- [INTAKE specification](docs/quality/intake.md): INTAKE.md artifact structure and requirements
- [PLAN specification](docs/quality/technical-plan.md): PLAN.md artifact structure and requirements
- [Rules index](rules/INDEX.md): All rules with always-apply and deprecated flags

---

## Workflow Version Tracking

When you export this workflow to a target project using `scripts/aidd-export.sh`, it creates `aidd/aidd.lock` in the target project:

```yaml
# AIDD Lock File
timestamp: 2024-01-15T10:30:00Z
source_remote: https://github.com/owner/aidd-flow
source_commit: abc123def456...
template_version: 1.0.0
```

Re-run `aidd-export.sh` from the source repository to update. Use `--backup` to preserve existing `aidd/` directory.

---

## Inspiration & lineage

This workflow is inspired by the **AI-Driven Development (AIDD)** approach articulated by Alex Soyes and the `ai-driven-dev` community ([github.com/ai-driven-dev](https://github.com/ai-driven-dev)).

**Important disclaimers:**

- This is **not an official** or verbatim implementation of AIDD
- This is a **personal, practical interpretation** adapted for IDE-agnostic use
- Any opinions, limitations, or mistakes in this implementation are the author's own

---

## Non-goals

This repository is **not**:

- **An official AIDD framework**: Personal implementation, not an official standard
- **A certification program**: No certification, training, or official endorsement
- **A universal methodology**: Designed for practical use, not theoretical completeness
- **An endorsement of tools**: IDE-agnostic design reflects practical choices, not tool endorsement
- **A static specification**: This workflow evolves based on real-world use

---

## License

See [LICENSE](LICENSE) file for details.

---

## Contributing

This repository represents a stable snapshot of an evolving workflow. Contributions that improve clarity, fix errors, or add practical improvements are welcome. Please open an issue to discuss significant changes before submitting a pull request.
