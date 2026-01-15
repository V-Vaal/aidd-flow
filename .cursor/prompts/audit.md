# Audit Prompt

## Purpose

Perform a comprehensive repository audit to understand current state, architecture, risks, and opportunities. This prompt guides systematic inspection of the codebase without inventing facts.

## Inputs Required

- Repository structure and directory layout
- README files and documentation
- Package configuration files (package.json, Cargo.toml, requirements.txt, go.mod, etc.)
- Source code files (contracts, main modules, key components)
- Test files and test configuration
- CI/CD configuration files (.github/workflows, .gitlab-ci.yml, etc.)
- Configuration files (docker-compose.yml, .env.example, etc.)

## Output Artefact

- Creates or updates: `.cursor/work/AUDIT.md`

## Procedure

1. **Inspect repository structure**
   - List top-level directories and their purposes
   - Identify main entry points (main files, index files, app files)
   - Note configuration files and their locations
   - Document build artifacts and generated files (if any)

2. **Read key documentation**
   - Read README.md (or README files) for project overview
   - Read CONTRIBUTING.md if present
   - Read LICENSE if present
   - Note any architecture documentation

3. **Analyze package configuration**
   - Read package manager files (package.json, Cargo.toml, requirements.txt, go.mod, etc.)
   - Extract dependencies and their versions
   - Identify build tools and scripts
   - Note development vs production dependencies

4. **Examine source code structure**
   - Identify main modules/components
   - Note architectural patterns (MVC, layered, microservices, etc.)
   - Review key source files to understand code organization
   - Document language(s) and frameworks in use

5. **Review test infrastructure**
   - List test directories and test files
   - Note test frameworks in use
   - Check for test configuration files
   - Assess test coverage if reports are available

6. **Inspect CI/CD setup**
   - Review CI/CD configuration files
   - Document build and test pipelines
   - Note deployment processes if visible
   - Identify quality gates

7. **Identify risks and sensitive areas**
   - Security concerns (hardcoded secrets, missing auth, etc.)
   - Technical debt (TODO comments, deprecated code, etc.)
   - Areas with high complexity or coupling
   - Missing error handling or validation
   - Outdated dependencies

8. **Identify quick wins**
   - Low-effort improvements (documentation, formatting, etc.)
   - Simple bug fixes or optimizations
   - Missing tests for critical paths
   - Configuration improvements

9. **Formulate recommendations**
   - Strategic improvements (architecture, patterns)
   - Refactoring opportunities
   - Process improvements (CI/CD, testing)
   - Security enhancements

10. **Document open questions**
    - Areas requiring further investigation
    - Unresolved architectural decisions
    - Unknown dependencies or assumptions

11. **Collect External Signals (GitHub)**
    - Check if `.cursor/work/github-signals.md` exists
    - If `github-signals.md` exists:
      - Read the file for facts-only data
      - Reference config file in AUDIT.md (if `.cursor/work/github-signals.config.yml` exists)
      - Restate filters used from config (if available)
      - Include retrieval method (MCP or manual) from github-signals.md
      - List results: counts, issues (id, title, state, labels, updated_at), PRs (same format)
    - If `github-signals.md` does NOT exist:
      - In "External Signals (GitHub)" section, write: "Not collected (Exploratory mode)"
      - Do NOT invent any signals or data
    - Facts only: no interpretation, analysis, or prioritization

12. **Create AUDIT.md**
    - Use exact headings:
      - `# Audit`
      - `## Repo Overview`
      - `## Current Architecture`
      - `## Tech Stack & Tooling`
      - `## Test / CI Status`
      - `## Risks & Sensitive Areas`
      - `## Quick Wins`
      - `## Recommendations`
      - `## Open Questions`
      - `## External Signals (GitHub)` (required)
      - `## Cross-analysis: Audit × GitHub Signals (AI-generated, non-binding)` (AI-only)
      - `## Action Candidates (AI-generated, non-binding)` (AI-only)
    - Fill each section with findings from steps 1-11
    - Base all content on actual repository inspection (do not invent facts)
    - External Signals: facts only (IDs, titles, labels, state, updated_at)
    - AI sections: clearly marked, non-binding, no decisions or prioritization
    - Save to `.cursor/work/AUDIT.md`

## Gate Reminders

- This audit is informational and does not require validation gates
- Use audit findings to inform INTAKE and PLAN creation
- Update `.cursor/memory/activeContext.md` if significant insights are discovered

## Definition of Done

- AUDIT.md exists at `.cursor/work/AUDIT.md`
- All required sections are present and filled
- External Signals (GitHub) section included (MCP or manual)
- Content is based on actual repository inspection (no invented facts)
- Findings are actionable and specific
- AI sections clearly marked as non-binding
- No decisions or prioritization in any section

