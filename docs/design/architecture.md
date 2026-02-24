# Framework Architecture

Architecture decisions and IDE integration guide for aidd-flow.

## Directory Structure

```
aidd-flow/
├── AGENTS.md              # Agent entry point (loaded automatically by OpenCode/Claude Code)
├── mcp.example.json       # MCP GitHub server template
├── .env.example           # Environment variables template
│
├── aidd/
│   ├── memory/            # Persistent memory bank (fill once per project)
│   ├── work/              # Runtime artifacts — gitignored (AUDIT, INTAKE, PLAN, REVIEW)
│   └── review/            # Domain-specific review checklists
│
├── docs/
│   ├── workflow/README.md # Complete workflow reference
│   ├── design/            # Architecture decisions (this file)
│   ├── plans/active/      # Active plans — gitignored
│   └── quality/           # Artifact specifications (intake, technical-plan)
│
├── rules/                 # Plain Markdown rules — load into agent context as needed
│   └── INDEX.md           # Rules catalog with always-apply and deprecated flags
│
├── prompts/               # Universal workflow prompts
│   └── commands/cursor/   # Cursor-specific slash commands (archived reference)
│
└── scripts/               # Validation gate scripts (bash, IDE-agnostic)
```

## Design Decisions

### Agnostic over IDE-specific

All workflow files (rules, prompts, memory, scripts) use plain Markdown and bash.
No IDE-specific syntax outside of `prompts/commands/cursor/` (archived reference only).

### Single entry point

`AGENTS.md` at repository root is the universal entry point.
- OpenCode and Claude Code load it automatically.
- Cursor users: reference it manually or use `prompts/commands/cursor/` slash commands.
- Other agents: copy the relevant section into your chat context.

### Tripartite role separation

Every task follows three phases enforced by gate scripts:
1. **Architect** — plan before building (`validate-plan.sh` gate)
2. **Editor** — build under constraints (rules + memory context)
3. **Reviewer** — human audit mandatory (`review-check.sh` gate)

### Runtime artifacts are gitignored

`aidd/work/` contains session artifacts (AUDIT.md, INTAKE.md, PLAN.md, REVIEW.md).
These are intentionally excluded from version control — they are ephemeral working documents.
Use `scripts/aidd-cleanup.sh` to archive artifacts older than 30 days.

### Memory bank is version-controlled

`aidd/memory/` contains persistent context files (projectbrief, techContext, systemPatterns, activeContext).
These ARE committed — they represent the stable, shared knowledge base for the project.

## MCP GitHub Setup

The GitHub MCP server enables structured, facts-only GitHub data retrieval during the Audit phase.

`mcp.example.json` is the template. Copy and configure it for your IDE:

### OpenCode

OpenCode reads MCP configuration from its global config file:
```
~/.config/opencode/config.json
```
Add the `mcpServers` block from `mcp.example.json` into your OpenCode config.

### Cursor

Optional: if you choose to configure Cursor in a target project, copy `mcp.example.json` content to `.cursor/mcp.json` in that project:
```bash
cp mcp.example.json .cursor/mcp.json
```

### Claude Code (claude.ai desktop)

Claude Code reads MCP from its project settings or global config.
Add the server definition from `mcp.example.json` to your Claude config.

### Environment variable

All configurations use `${env:GITHUB_TOKEN}`. Set it before launching your IDE:
```bash
export GITHUB_TOKEN=your_token_here
```
Or add to your shell profile (`~/.bashrc`, `~/.zshrc`).

The `.env.example` file documents all required environment variables.

## Exporting to a Target Project

Use `scripts/aidd-export.sh` to install this framework into any existing project:

```bash
bash scripts/aidd-export.sh /path/to/your/project
```

This copies:
- `rules/` → target `rules/`
- `prompts/` → target `prompts/`
- `aidd/memory/` → target `aidd/memory/`
- `aidd/review/` → target `aidd/review/`
- `scripts/` → target `scripts/`
- Creates `aidd/aidd.lock` in target with version info

After export, copy `mcp.example.json` to your IDE's MCP config location (see MCP Setup above).
