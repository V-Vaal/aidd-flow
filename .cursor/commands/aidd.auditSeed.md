# AIDD Audit Seed Command

## Purpose

Populate factual sections of AUDIT.md by analyzing the repository and GitHub signals. This command seeds the audit with evidence-based content while maintaining strict separation between facts and AI-generated analysis.

## Usage

1. **Read inputs**: Load `.cursor/work/AUDIT.md` and `.cursor/work/github-signals.md` (if present)
2. **Analyze repository**: Inspect codebase structure, files, and configuration
3. **Populate sections**: Fill factual sections with evidence, populate AI sections with non-binding analysis
4. **Update artifact**: Write populated content to `.cursor/work/AUDIT.md`

## Inputs

- **Required**: `.cursor/work/AUDIT.md` (template or existing audit)
- **Optional**: `.cursor/work/github-signals.md` (if present, use for External Signals section)

## Procedure

### Step 1: Read Input Files

1. Read `.cursor/work/AUDIT.md` to understand current state
2. Check if `.cursor/work/github-signals.md` exists
3. If github-signals.md exists, read it for External Signals data
4. If github-signals.md missing, External Signals section remains template/empty

### Step 2: Populate Factual Repo Sections

**Hard rule: Do-not-invent policy**
- Every claim must cite a file path or command output
- If evidence is missing, add to "Open Questions" section
- Never guess endpoints, patterns, conventions, or versions

**## Repo Overview**
- Read README.md, package.json, or main entry files
- Cite source: `README.md`, `package.json:name`, etc.
- Document purpose, current state, and key characteristics
- If unclear, add to Open Questions

**## Current Architecture**
- Inspect directory structure: `src/`, `lib/`, `app/`, etc.
- Identify main components and their locations
- Cite file paths: `src/components/`, `lib/services/`, etc.
- Document patterns found (MVC, layered, microservices, etc.)
- If architecture unclear, add to Open Questions

**## Tech Stack & Tooling**
- Read package manager files: `package.json`, `Cargo.toml`, `requirements.txt`, `go.mod`, etc.
- Extract dependencies and versions with citations
- Identify frameworks and tools in use
- Cite configuration files: `package.json:dependencies`, `.github/workflows/`, etc.
- If versions or tools unclear, add to Open Questions

**## Test / CI Status**
- Inspect test directories: `tests/`, `__tests__/`, `spec/`, etc.
- Read CI configuration: `.github/workflows/`, `.gitlab-ci.yml`, etc.
- Check for test frameworks: `jest.config.js`, `pytest.ini`, etc.
- Cite test files and CI configs
- Document coverage if reports exist (cite report path)
- If test infrastructure unclear, add to Open Questions

**## Risks & Sensitive Areas**
- Search for security patterns: hardcoded secrets, missing auth, etc.
- Identify technical debt: TODO comments, deprecated code
- Cite specific file paths and line numbers
- Document complexity hotspots with evidence
- If risks uncertain, add to Open Questions

**## Quick Wins**
- Identify low-effort improvements with evidence
- Cite specific files or patterns that can be improved
- Document simple fixes or optimizations found
- If no quick wins identified, leave empty or state "None identified"

**## Recommendations**
- Strategic improvements based on evidence
- Cite architectural patterns or code locations
- Refactoring opportunities with file references
- Process improvements (CI/CD, testing) with config citations
- If no recommendations, leave empty or state "None identified"

**## Open Questions**
- Areas requiring further investigation
- Unresolved architectural decisions
- Unknown dependencies or assumptions
- Missing evidence for claims
- Questions raised during analysis

### Step 3: Populate External Signals (GitHub)

**If `.cursor/work/github-signals.md` exists:**

1. Read the github-signals.md file
2. Extract query configuration from the file
3. Extract results summary (counts)
4. Extract issues and PRs lists
5. Populate "External Signals (GitHub)" section in AUDIT.md with:
   - Reference to `.cursor/work/github-signals.config.yml`
   - Restate filters used (from github-signals.md)
   - Retrieval method (MCP or manual, from github-signals.md)
   - Results summary (counts from github-signals.md)
   - Issues list (exact format from github-signals.md)
   - PRs list (exact format from github-signals.md)

**Strict rules:**
- Use data ONLY from github-signals.md
- Do NOT fetch or interpret GitHub data directly
- Do NOT add analysis or interpretation
- Copy facts exactly as they appear in github-signals.md

**If `.cursor/work/github-signals.md` does NOT exist:**
- Leave External Signals section as template/empty
- Do NOT attempt to fetch GitHub data
- Do NOT create github-signals.md

### Step 4: Populate AI Non-Binding Sections

**## Cross-analysis: Audit × GitHub Signals (AI-generated, non-binding)**

**Rules:**
- Only populate if both audit findings AND GitHub signals exist
- Facts-based correlation only
- No recommendations or "you should" language
- No prioritization
- Clearly mark as AI-generated and non-binding

**Content:**
- Correlate codebase findings with GitHub signals
- Identify patterns or connections
- Present facts and observations only
- Example: "Issue #123 mentions authentication bug; audit found auth code in `src/auth/`"
- No action items or decisions

**If GitHub signals missing:**
- Leave section empty or state "No GitHub signals available for cross-analysis"

**## Action Candidates (AI-generated, non-binding)**

**Rules:**
- Generate potential actions based on audit findings
- Candidates only, no priority ordering
- No "you should" or imperative language
- No decisions or recommendations
- Clearly mark as AI-generated and non-binding

**Content:**
- List potential actions as neutral candidates
- Base on audit findings and GitHub signals (if available)
- Format: "Candidate: [description]" or bullet points
- Example: "Candidate: Address authentication issues mentioned in GitHub signals"
- No prioritization, no "should", no decisions

**If no candidates identified:**
- Leave empty or state "No action candidates identified"

### Step 5: Validation and Output

**Before writing:**
- Verify all factual claims have file path citations
- Verify no invented facts (endpoints, versions, patterns)
- Verify External Signals only from github-signals.md (if present)
- Verify AI sections marked as non-binding
- Verify no "you should" language in AI sections
- Verify Open Questions includes missing evidence

**Write to `.cursor/work/AUDIT.md`:**
- Update all populated sections
- Preserve template structure
- Maintain clear separation: facts vs AI analysis
- Ensure all citations are present

## Hard Rules

### Do-Not-Invent Policy
- **Never guess**: endpoints, routes, API versions, regex patterns, migration conventions, versioning schemes
- **Always cite**: file paths, command outputs, configuration values
- **If uncertain**: add to Open Questions, do not invent

### Evidence Requirements
- Repo Overview: cite README, package files, entry points
- Architecture: cite directory structure, component files
- Tech Stack: cite package.json, requirements.txt, config files
- CI/Test: cite test files, CI configs, coverage reports
- Risks: cite specific file paths and line numbers

### External Signals Rules
- Use ONLY data from github-signals.md
- Do NOT fetch GitHub data directly
- Do NOT interpret or analyze signals
- Copy facts exactly as provided

### AI Sections Rules
- Mark clearly as "AI-generated, non-binding"
- Facts-based only, no recommendations
- No "you should" language
- No prioritization
- No decisions

### Workflow Boundaries
- **MUST NOT** create or modify `.cursor/work/INTAKE.md`
- **MUST NOT** create or modify `.cursor/work/PLAN.md`
- **MUST NOT** make decisions or recommendations
- **MUST** only populate AUDIT.md with facts and non-binding analysis

## Output Format

The updated AUDIT.md should contain:

1. **Factual sections** (populated with evidence):
   - Repo Overview (with citations)
   - Current Architecture (with file paths)
   - Tech Stack & Tooling (with config citations)
   - Test / CI Status (with test/CI file citations)
   - Risks & Sensitive Areas (with file:line citations)
   - Quick Wins (with evidence)
   - Recommendations (with evidence)
   - Open Questions (including missing evidence)

2. **External Signals** (if github-signals.md exists):
   - Query reference and filters
   - Retrieval method
   - Results summary
   - Issues and PRs lists (exact copy from github-signals.md)

3. **AI sections** (non-binding):
   - Cross-analysis (facts-based, no recommendations)
   - Action Candidates (candidates only, no priority)

## Quick Reference

- **Input**: `.cursor/work/AUDIT.md`, `.cursor/work/github-signals.md` (optional)
- **Output**: `.cursor/work/AUDIT.md` (updated)
- **Rules**: Do-not-invent, cite evidence, mark AI sections, no INTAKE/PLAN modification
- **Boundaries**: Audit only, no decisions, no workflow artifacts
