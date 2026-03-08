> 🇬🇧 English (default) | 🇫🇷 [Version française](README.fr.md)

# aidd-flow

A structured, IDE-agnostic implementation of an AI-Driven Development (AIDD) workflow focused on orchestration, checkpoints, and auditability. Works with OpenCode, Claude Code, Cursor, GitHub Copilot, or any LLM-based agent.

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

This exports the full workflow into `/path/to/your/target-project/.aidd-flow/`, creates a root `AGENTS.md` entry point from template, and writes `.aidd-flow/aidd/aidd.lock` for version tracking.

Safety behavior:
- If `.aidd-flow/` exists and is non-empty, the script refuses unless you pass `--force` or `--backup`.
- If `AGENTS.md` already exists at the target root, the script refuses unless you pass `--force-agents` or `--backup-agents`.

After export, authenticate GitHub CLI (`gh auth login`) and review `docs/design/architecture.md`.

---

## Quickstart

`AGENTS.md` is the universal entry point. It is loaded automatically by OpenCode and Claude Code. The `prompts/commands/cursor/` folder is a historical archive you can use as inspiration to recreate Cursor slash commands.

### Prerequisites

- Any AI agent (OpenCode, Claude Code, Cursor agent mode, GitHub Copilot Chat, ...)
- Git repository with the workflow installed (see [Installation](#installation))
- GitHub CLI authenticated (`gh auth login`) for targeted mode
- `curl` available for Context7 docs (`scripts/c7-docs.sh`)
- Optional: set `CONTEXT_BUDGET=low|medium|high` in `.env` to control context size (default: `low`)

### The three-phase workflow

**Phase 1 — Architect** (plan before you build)

1. Read `aidd/memory/activeContext.md` and `aidd/memory/projectbrief.md`
2. Load `prompts/intake.md` → produces `aidd/work/INTAKE.md`
3. Load `prompts/plan.md` → produces `aidd/work/PLAN.md`
4. Run gate: `bash scripts/validate-plan.sh` — do not proceed if it fails

**Phase 2 — Editor** (build under constraints)

5. Run `bash scripts/aidd-rules-jit.sh` → produces `aidd/work/RULES_JIT.md` with the minimal relevant rule set
6. Implement following `aidd/work/PLAN.md` exactly — no scope creep
7. Run: `bash scripts/aidd-check.sh`

**Phase 3 — Reviewer** (human audit mandatory)

8. Load `prompts/review.md` → produces `aidd/work/REVIEW.md`
9. Run gate: `bash scripts/review-check.sh` — task is not done until Verdict is `APPROVE`
10. Optional closeout: `bash scripts/aidd-finish.sh` (guided commit/push/PR + cleanup + handoff)

### IDE-specific shortcuts

| Agent | Entry point |
|-------|-------------|
| OpenCode / Claude Code | `AGENTS.md` loaded automatically at session start |
| Cursor | Historical archive in `prompts/commands/cursor/` — not plug-and-play, use as inspiration for slash commands |
| Other agents | Copy the relevant `prompts/*.md` content into your chat context |

**Claude Code note:** `AGENTS.md` is the project-scoped entry point. Claude Code also maintains its own cross-project memory at `~/.claude/` — these two layers are complementary: `aidd/memory/` holds project context, `~/.claude/` holds agent-level preferences and patterns. Use `prompts/compact-response.md` as a reference template when you need token-efficient outputs.

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
├── .env.example               # Optional environment defaults
│
├── aidd/
│   ├── memory/                # Persistent context — fill once per project
│   ├── work/                  # Runtime artifacts — gitignored (AUDIT, INTAKE, PLAN, REVIEW, SUMMARY, HANDOFF)
│   └── review/                # Domain-specific review checklists (web3, ml, general)
│
├── rules/                     # 30+ plain Markdown rules
│   └── INDEX.md               # Rules catalog (always-apply, stack-specific, deprecated)
│
├── prompts/                   # Workflow prompts (start, intake, plan, audit, review, ...)
│   ├── compact-response.md    # Token-efficient output template
│   └── commands/cursor/       # Cursor slash commands (archived reference)
│
├── scripts/                   # Validation gate scripts
│   ├── validate-plan.sh       # Gate: blocks implementation if PLAN.md is invalid
│   ├── review-check.sh        # Gate: blocks completion if REVIEW.md is not APPROVE
│   ├── aidd-check.sh          # Post-implementation checks
│   ├── aidd-finish.sh         # Guided commit/push/PR + cleanup + handoff
│   ├── aidd-export.sh         # Export framework to a target project
│   ├── gh-context.sh          # Facts-only GitHub signals via gh CLI
│   ├── c7-docs.sh             # Context7 docs via curl (mandatory evidence)
│   ├── aidd-rules-jit.sh      # Just-in-time rules selection
│   ├── aidd-diff-digest.sh    # Compact diff digest for reviews
│   ├── aidd-verify-ui.sh      # UI change verification
│   └── aidd-cleanup.sh        # Archive aidd/work/ artifacts older than 30 days
│
└── docs/
    ├── workflow/              # Complete workflow reference (overview, gates, governance, debugging, ...)
    ├── design/architecture.md  # Export guide and architecture decisions
    ├── templates/AGENTS.root.md  # Root AGENTS template used by export
    └── quality/               # Artifact specifications (intake, technical-plan)
```

---

## Documentation

- [Workflow guide](docs/workflow/README.md): Complete workflow method with gates, governance, and troubleshooting
- [Architecture guide](docs/design/architecture.md): Export model and design decisions
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

Re-run `aidd-export.sh` from the source repository to update. Use `--backup` to preserve existing `.aidd-flow/` directory.

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
