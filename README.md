> 🇬🇧 English (default) | 🇫🇷 [Version française](README.fr.md)

# aidd-flow

An opinionated, Cursor-first implementation of an AI-Driven Development (AIDD) workflow focused on orchestration, checkpoints, and auditability.

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

`aidd-flow` is a practical, Cursor-first implementation of an AIDD workflow. This repository provides:

- **Orchestration**: Structured commands and prompts that guide the workflow
- **Checkpoints**: Validation gates that enforce plan quality and review verdicts
- **Auditability**: Persistent artifacts (AUDIT, INTAKE, PLAN, REVIEW) that document decisions and rationale
- **Cursor integration**: Commands and rules optimized for Cursor IDE's agent mode

This workflow focuses on **how to structure AI-assisted work** rather than code generation alone. It provides a repeatable process for going from requirements to reviewed implementation with clear separation between exploration, planning, execution, and publication.

---

## Scope of this workflow

### What this repository helps with

- **Structured AI-assisted development**: From issue/PR to reviewed implementation
- **Decision traceability**: Clear artifacts documenting what was decided and why
- **Quality gates**: Automated validation of plans and mandatory human review
- **Project continuity**: Memory bank and active context for multi-session work
- **Cursor-first workflows**: Commands and prompts optimized for Cursor IDE

### What this repository does not attempt to solve

- **Universal methodology**: This is a practical workflow, not a theoretical framework
- **Tool-agnostic workflows**: Optimized for Cursor, not designed for other IDEs in this version (future evolution possible)
- **Team collaboration**: Designed for individual or small team use, not enterprise-scale processes
- **Certification or training**: No official certification or training program

---

## Installation

### Option 1: Clone this repository to use the workflow directly or as a reference for exporting to other projects:

```bash
git clone https://github.com/V-Vaal/aidd-flow.git
cd aidd-flow
```

Then open the repository in Cursor and use `@aidd.start` directly.

### Option 2: Export workflow to an existing project

If you want to apply this workflow to an existing project:

```bash
# Clone this repository
git clone https://github.com/V-Vaal/aidd-flow.git
cd aidd-flow

# Export the workflow to your target project
bash scripts/aidd-export.sh /path/to/your/target-project
```

The export script copies all workflow files (commands, prompts, rules, scripts) into your target project's `.cursor/` directory. After export, open your target project in Cursor and use `@aidd.start`.

**Note**: The export script creates a `.cursor/aidd.lock` file to track the workflow version installed in your project.

---

## Quickstart

The entry point is the `@aidd.start` command in Cursor.

### Prerequisites

- Cursor IDE with agent mode
- Git repository (local or remote) with the workflow installed (see [Installation](#installation))
- (Optional) GitHub MCP for targeted mode

### Start the workflow

1. **Open Cursor** in your project directory

2. **Run the start command**:
   ```
   @aidd.start
   ```

3. **Select a mode**:
   - **Targeted (Issue/PR)**: Fetch GitHub signals for a specific issue or PR, then run full workflow
   - **Exploratory (Repo scan)**: Run repository audit to produce findings

4. **Follow the interactive flow**: The command guides you through mode-specific steps

5. **Review artifacts**: Generated artifacts appear in `.cursor/work/`:
   - `AUDIT.md`: Repository analysis and findings
   - `INTAKE.md`: Requirements and constraints (targeted mode)
   - `PLAN.md`: Technical implementation plan (targeted mode)
   - `REVIEW.md`: Review verdict and evidence (after implementation)

### Next steps after start

- **Targeted mode**: Review AUDIT → INTAKE → PLAN, then proceed to implementation
- **Exploratory mode**: Review findings, select a finding to convert to a targeted run

For detailed workflow steps, see the [workflow documentation](docs/workflow.md).

---

## Core design principles

If you want better code, improve the system, not the model.

This workflow does not attempt to "make AI smarter".
It focuses on improving the conditions under which code is produced:
clear constraints, explicit plans, validation gates, and human review.

### Human in-the-loop decision points

Critical decisions require human judgment:
- **Intake validation**: Human reviews and approves requirements
- **Plan approval**: Human validates technical approach before implementation
- **Review verdict**: Human provides formal approval (APPROVE | CHANGES_REQUESTED)

### Clear separation between exploration, execution, and publication

- **Exploration**: Audit and discovery (exploratory mode)
- **Planning**: Requirements and technical design (targeted mode)
- **Execution**: Implementation with AI assistance
- **Verification**: Automated checks and human review
- **Publication**: Approved changes only

### Auditability and traceability

All AI-assisted work produces structured artifacts:
- **AUDIT.md**: Repository state and findings
- **INTAKE.md**: Requirements, constraints, acceptance criteria
- **PLAN.md**: Technical steps, files to touch, rollback plan
- **REVIEW.md**: Review summary, test evidence, formal verdict

These artifacts document **what was decided**, **why it was decided**, and **what evidence supports the decision**.

### Explicit role separation

- **Human as orchestrator**: Sets rules, validates plans, makes decisions, provides verdicts
- **AI as executor**: Implements plans under constraints, follows rules, generates artifacts

---

## Inspiration & lineage

This workflow is inspired by the **AI-Driven Development (AIDD)** approach articulated by Alex Soyes and the `ai-driven-dev` community.

**Important disclaimers:**

- This is **not an official** or verbatim implementation of AIDD
- This is a **personal, practical interpretation** optimized for Cursor IDE
- Any opinions, limitations, or mistakes in this implementation are the author's own
- This repository represents a **stable snapshot** extracted from an internal sandbox

The original AIDD approach emphasizes human leadership, explicit constraints, and structured workflows. This repository adapts those principles into a Cursor-first, command-driven workflow with validation gates and auditability.

---

## Non-goals

This repository is **not**:

- **An official AIDD framework**: This is a personal implementation, not an official standard
- **A certification program**: No certification, training, or official endorsement
- **A universal methodology**: Designed for practical use, not theoretical completeness
- **An endorsement of tools**: Cursor-first design reflects practical choices, not tool endorsement
- **A marketing product**: Factual documentation, no promotional language
- **A static specification**: This workflow evolves based on real-world use

---

## Repository structure

```
aidd-flow/
├── .cursor/
│   ├── commands/          # Cursor commands (aidd.start, aidd.intake, etc.)
│   ├── prompts/          # Workflow prompts (start, intake, plan, review)
│   ├── rules/            # Cursor rules (architecture, conventions, security)
│   ├── memory/            # Template memory bank files
│   ├── review/            # Domain-specific review checklists
│   └── work/              # Generated artifacts (AUDIT, INTAKE, PLAN, REVIEW)
├── scripts/              # Validation gates and utility scripts
│   └── aidd-export.sh     # Export workflow to target project (see Installation)
├── docs/                 # Workflow documentation
└── README.md
```

---

## Documentation

- [Workflow guide](docs/workflow.md): Complete workflow method with gates, troubleshooting, and sanity checks
- [INTAKE specification](docs/intake.md): INTAKE.md artifact structure and requirements
- [PLAN specification](docs/technical-plan.md): PLAN.md artifact structure and requirements

---

## Workflow Version Tracking

When you export this workflow to a target project using `scripts/aidd-export.sh`, it creates `.cursor/aidd.lock` in the target project:

```yaml
# AIDD Lock File
timestamp: 2024-01-15T10:30:00Z
source_remote: https://github.com/V-Vaal/aidd-flow
source_commit: abc123def456...
template_version: 1.0.0
```

**Purpose:**
- Tracks which workflow version is installed in the target project
- Records source repository and commit SHA
- Enables version-aware updates and troubleshooting

**Updating workflow in target project:**
- Re-run `aidd-export.sh` from the source repository
- The lock file is updated with new version information
- Use `--backup` flag to preserve existing `.cursor/` directory

**Version information:**
- `source_commit`: Git SHA when available, or "uncommitted" if no valid commit
- `source_remote`: Repository URL if remote is configured, otherwise omitted
- `template_version`: Version identifier (if tracked in source repository)

---

## License

See [LICENSE](LICENSE) file for details.

---

## Contributing

This repository represents a stable snapshot of an evolving workflow. Contributions that improve clarity, fix errors, or add practical improvements are welcome. Please open an issue to discuss significant changes before submitting a pull request.
