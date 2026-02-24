# Start Prompt

## Purpose

Guide the operator through AIDD workflow initiation, supporting two distinct modes: Targeted (Issue/PR) and Exploratory (Repo scan).

## Procedure

### Step 1: Mode Selection

**Ask the user:**
> "Select mode:
> - **A) Targeted (Issue/PR)**: Fetch GitHub signals for a specific issue or PR
> - **B) Exploratory (Repo scan)**: Run repository audit to produce findings"

**Wait for user response:**
- If "A" or "Targeted" → proceed to Step 2A
- If "B" or "Exploratory" → proceed to Step 2B

### Step 2A: Targeted Mode Setup

**2A.1: Ask for type**
> "Issue or PR?"

**Wait for user response:**
- Record type: `issue` or `pr`

**2A.2: Ask for number**
> "Enter number (e.g., 123):"

**Wait for user response:**
- Record number: `[number]`
- If user provides empty/default response, proceed to Target Gate check (Step 2A.3)

**2A.3: Target Gate (Check Existing Target)**

**Read existing config:**
- Check if `aidd/work/github-signals.config.yml` exists
- If exists, read current content and parse YAML
- If missing, create minimal template

**Target Gate Logic:**
- **If config contains `target` block:**
  - Extract existing `target.type` and `target.number`
  - **If user provided new type/number AND it differs from existing:**
    - Override: Update `target.type` and `target.number` with new values
    - Log override: "Target overridden (was {existing_type} #{existing_number}, now {new_type} #{new_number})"
    - Write this log message to console/output (will be recorded in github-signals.md later)
  - **If user did NOT provide type/number (or accepted default):**
    - Reuse existing target: Keep `target.type` and `target.number` unchanged
    - Log reuse: "Reusing existing target: {type} #{number}"
- **If config does NOT contain `target` block:**
  - Use user-provided type/number (from Steps 2A.1 and 2A.2)
  - If user did not provide, ask for both type and number

**2A.4: Target Reset / Isolation Gate**

**Purpose:** Prevent state contamination when target changes. Archive previous artifacts if target identity differs.

**Compute target identity:**
- After Target Gate (Step 2A.3), extract final target identity:
  - `repo`: from config (owner/name format)
  - `type`: from config `target.type` (issue|pr)
  - `number`: from config `target.number`
- Construct identity string: `{repo}|{type}|{number}` (e.g., `octocat/Hello-World|issue|123`)

**Check RUN_STATE:**
- Read `aidd/work/RUN_STATE.json` if it exists
- Parse JSON to extract previous target identity:
  ```json
  {
    "repo": "owner/name",
    "type": "issue",
    "number": 123,
    "timestamp": "2024-01-15T10:30:00Z"
  }
  ```
- Construct previous identity string: `{prev_repo}|{prev_type}|{prev_number}`

**Reset Gate Logic:**

- **If RUN_STATE does NOT exist:**
  - No previous run detected
  - Proceed normally (fresh run)
  - Create RUN_STATE.json after successful run (in Step 2A.6)

- **If RUN_STATE exists AND target identity matches:**
  - Same target as previous run
  - Proceed normally (normal rerun, reuse artifacts)
  - Update RUN_STATE.json timestamp after successful run

- **If RUN_STATE exists AND target identity differs:**
  - Target changed: `{prev_repo}|{prev_type}|{prev_number}` → `{new_repo}|{new_type}|{new_number}`
  - **Trigger Reset Gate (Option A: Automatic Archive + Reset):**
    1. Create archive folder: `aidd/work/_archive/{timestamp}-{prev_repo}-{prev_type}-{prev_number}/`
       - Format timestamp: `YYYYMMDD-HHMMSS` (e.g., `20240115-103000`)
       - Sanitize repo name: replace `/` with `-` (e.g., `octocat-Hello-World`)
    2. Move existing artifacts to archive:
       - `TARGET.md` → archive
       - `github-signals.md` → archive
       - `AUDIT.md` → archive
       - `INTAKE.md` → archive
       - `PLAN.md` → archive
       - `REVIEW.md` → archive (if exists)
       - `github-signals.config.yml` → archive (backup copy, keep original for new run)
       - `RUN_STATE.json` → archive
    3. **Do NOT archive:** `CHECKLIST.md`, `DEBUG.md`, `PR.md`, `ARCHITECT_PACKET.md` (non-target-specific)
    4. Log reset action:
       - Console: "Target changed from {prev_type} #{prev_number} to {new_type} #{new_number} -> archived previous artifacts to aidd/work/_archive/{archive_folder}/ -> fresh run started"
       - This message will be visible to operator
    5. Proceed with fresh run (artifacts will be regenerated)

**Implementation notes:**
- Use simple file operations (mv/cp commands or equivalent)
- Archive folder name must be deterministic and readable
- Preserve original `github-signals.config.yml` (don't archive the only copy, keep it for new run)
- Archive is a safety backup; operator can manually recover if needed

**2A.5: Ensure github-signals.config.yml**

**Update config minimally:**
- Set `repo: owner/name` (if not present, ask user: "Repository owner/name (e.g., octocat/Hello-World):")
  - **YAML Writing Safety**: When updating `repo:`, use full line replacement:
    - Find line matching pattern `^repo:\s*.*$` (entire line)
    - Replace entire line with `repo: {owner}/{name}` (no concatenation)
    - If line doesn't exist, add it after the YAML header comments
- Ensure `target` block at top-level (from Target Gate result):
  ```yaml
  target:
    type: [issue|pr]  # from Target Gate (reused or overridden)
    number: [number]  # from Target Gate (reused or overridden)
  ```
  - **YAML Writing Safety**: When updating `target:` block, use block replacement:
    - Find `target:` block (lines starting with `target:` and indented `type:`/`number:`)
    - Replace entire block (all lines from `target:` to last indented line)
    - If block doesn't exist, add it after `repo:` line
    - **CRITICAL**: `target` must be at top-level (same level as `repo`, `issues`, `prs`), not nested under `issues` or `prs`
- Add `context` block for Related Context collection (optional, defaults enabled):
  ```yaml
  context:
    extract_references: true  # Extract references from target issue/PR
    search_keywords: []  # Optional: keywords for similar issues/PRs search
    # If empty, keywords will be auto-derived from target Issue/PR (title, labels, body, identifiers)
    # Derived keywords are written to config and recorded in github-signals.md
    # To override: provide keywords here before running the command
    include_closed_issues_limit: 10
    include_merged_prs_limit: 10
  ```
- Preserve existing `issues:`/`prs:` filters if they exist (do not remove user-defined filters)
- **Do NOT invent**: If repo owner/name is missing, ask user. Do not guess.

**Write config:**
- Update or create `aidd/work/github-signals.config.yml`
- Preserve existing fields when possible
- **YAML Writing Safety Rules:**
  - Always use full line/block replacement, never inline concatenation
  - For `repo:`: Replace entire line matching `^repo:\s*.*$`
  - For `target:`: Replace entire block (from `target:` to last indented property)
  - For `context.search_keywords`: Replace entire list (from `search_keywords:` to closing `]`)
  - Never append to existing values (e.g., avoid `repo: owner/namerepo: ...`)

**2A.6: Create TARGET.md (optional but recommended)**

Create `aidd/work/TARGET.md` with facts only:
```markdown
# Target

**Mode:** Targeted (Issue/PR)
**Type:** [issue|pr]
**Number:** [number]
**Repository:** [owner/name]
**Timestamp:** [ISO 8601 timestamp]
```

**CRITICAL: File Writing Safety**
- Always write TARGET.md as a fresh file (overwrite, not append)
- Use full file replacement, never concatenate lines
- Same rule applies to: github-signals.md, AUDIT.md, INTAKE.md, PLAN.md, REVIEW.md

**2A.7: Update RUN_STATE.json**

After successful run completion (or after Step 2A.6 if creating TARGET.md):
- Create or update `aidd/work/RUN_STATE.json`:
  ```json
  {
    "repo": "{owner/name}",
    "type": "{issue|pr}",
    "number": {number},
    "timestamp": "{ISO 8601 timestamp}"
  }
  ```
- Use current target identity (from Step 2A.4)
- Timestamp: Current ISO 8601 timestamp (e.g., `2024-01-15T10:30:00Z`)
- **File Writing Safety**: Write entire JSON file (overwrite, not append)

**2A.8: Execute sequence**

Run commands in order:

1. **prompts/start.md (GitHub signals step)**
   - Reads `aidd/work/github-signals.config.yml`
   - If config contains `target`, MUST fetch exactly that Issue/PR by number via MCP (preferred), otherwise fall back to manual retrieval and record method
   - **Keyword Derivation**: If `context.search_keywords` is empty or missing, derives keywords from target Issue/PR:
     - Extracts from title, labels, and body
     - Includes identifiers: CamelCase tokens (contracts/classes), function names, on-chain IDs
     - Filters out generic verbs (add, fix, update, should, improve, change)
     - Limited to 8 keywords maximum
     - Writes derived keywords to config and records them in github-signals.md under "## Analysis Keywords"
     - If keywords are provided in config, skips derivation but still records them as "Final (used)"
   - **Related Context collection**: If `context.extract_references` is true (default for targeted mode), also collects:
     - Direct references from target issue/PR body and comments (#123, owner/repo#123, URLs)
     - Similar closed issues and merged PRs (using "Final (used)" keywords from derivation or config)
     - Potential constraints/decisions inferred from related context
   - Produces `aidd/work/github-signals.md` with "Analysis Keywords" and "Related Context" sections (when applicable)
   - Uses GitHub MCP if available, with fallback to REST API, gh CLI, or manual instructions

2. **prompts/audit.md**
   - Reads `aidd/work/AUDIT.md` (create template if missing)
   - Reads `aidd/work/github-signals.md` (from step 1)
   - Populates `aidd/work/AUDIT.md` with facts and analysis

3. **prompts/intake.md**
   - Follows `prompts/intake.md`
   - Produces `aidd/work/INTAKE.md` (draft)

4. **prompts/plan.md**
   - Follows `prompts/plan.md`
   - Produces `aidd/work/PLAN.md` (draft)

5. **bash scripts/validate-plan.sh**
   - Runs `bash scripts/validate-plan.sh`
   - **Gate**: If validation fails, stop and inform user

**2A.6: Output next steps**

Display checklist:
```markdown
## Next Steps

- [ ] Review `aidd/work/AUDIT.md` for audit findings
- [ ] Review `aidd/work/INTAKE.md` for requirements
- [ ] Review `aidd/work/PLAN.md` for technical plan
- [ ] Go to UI ChatGPT for architect validation (AUDIT/INTAKE/PLAN)
- [ ] After validation, proceed with implementation
- [ ] Run `prompts/review.md` after implementation
```

### Step 2B: Exploratory Mode

**2B.1: Create TARGET.md (optional but recommended)**

Create `aidd/work/TARGET.md` with facts only:
```markdown
# Target

**Mode:** Exploratory (Repo scan)
**Repository:** [detect from current directory or ask]
**Timestamp:** [ISO 8601 timestamp]
```

**2B.2: Ensure AUDIT.md template exists**

- Check if `aidd/work/AUDIT.md` exists
- If missing, create with standard template structure (from `prompts/audit.md` reference)

**2B.3: Execute audit**

Run **prompts/audit.md**:
- Reads `aidd/work/AUDIT.md`
- Analyzes repository structure
- Populates factual sections with evidence
- **Do NOT require** `aidd/work/github-signals.md` (it may not exist)

**2B.4: Mark AUDIT.md as Exploratory**

After `prompts/audit.md` completes, update `aidd/work/AUDIT.md`:

**Add at the top (after title):**
```markdown
# Audit

**Mode:** Exploratory (Repo scan)
**Purpose:** Repository-wide analysis to identify findings and backlog candidates
```

**Ensure "Findings / Backlog candidates" section exists:**

If not present, add after "Action Candidates" section:
```markdown
## Findings / Backlog candidates

[Facts-based findings from audit. Each finding should be:
- Specific and evidence-based (cite file paths)
- Non-prescriptive (suggestions only, no "you should")
- Suitable for conversion to Targeted runs]

Examples:
- Finding: "Authentication code in `src/auth/` has TODO comments (lines 45, 67)"
- Finding: "Missing tests for `lib/payment/processor.ts` (no test file found)"
- Finding: "Outdated dependency: `package.json` lists react@16.8.0 (current: 18.x)"
```

**2B.5: Output next steps**

Display checklist:
```markdown
## Next Steps

- [ ] Review `aidd/work/AUDIT.md` for findings
- [ ] Select a finding from "Findings / Backlog candidates" section
- [ ] Convert finding to Targeted run:
  - Create GitHub issue/PR (if applicable)
  - Run `prompts/start.md` in Targeted mode with issue/PR number
  - OR manually create INTAKE.md based on finding
- [ ] Go to UI ChatGPT for architect validation if proceeding with a finding
```

## Hard Rules

### Do-Not-Invent Policy
- **Never guess**: repository owner/name, issue/PR metadata
- **Always ask**: If repo owner/name missing in config, ask user
- **Minimal config**: Only update github-signals.config.yml with user-provided data

### Mode Boundaries
- **Targeted mode**: Requires GitHub MCP (or manual fallback), full workflow
- **Exploratory mode**: No GitHub MCP required, audit-only

### Workflow Boundaries
- **Do NOT skip validation gates**: Targeted mode must run validate-intake.sh (after intake) and validate-plan.sh (before implementation)
- **Do NOT create INTAKE/PLAN in Exploratory**: Only AUDIT.md
- **Do NOT invent findings**: All findings must cite evidence (file paths, line numbers)

### TARGET.md Rules
- Facts only: mode, type, number, repo, timestamp
- No analysis or recommendations
- Optional but recommended for traceability

## Output Format

### Targeted Mode Artifacts
- `aidd/work/TARGET.md` (optional)
- `aidd/work/github-signals.config.yml` (updated/created)
- `aidd/work/github-signals.md` (from prompts/start.md (GitHub signals step))
- `aidd/work/AUDIT.md` (populated by prompts/audit.md)
- `aidd/work/INTAKE.md` (draft, from prompts/intake.md)
- `aidd/work/PLAN.md` (draft, from prompts/plan.md)

### Exploratory Mode Artifacts
- `aidd/work/TARGET.md` (optional)
- `aidd/work/AUDIT.md` (populated by prompts/audit.md, marked as Exploratory)
- `aidd/work/AUDIT.md` includes "Findings / Backlog candidates" section

## Quick Reference

- **Mode A (Targeted)**: Issue/PR → github-signals → audit → intake → plan → validate
- **Mode B (Exploratory)**: audit → findings → convert to Targeted later
- **Config**: `aidd/work/github-signals.config.yml` (Targeted mode only)
- **Target**: `aidd/work/TARGET.md` (optional, both modes)
- **Validation**: `bash scripts/validate-intake.sh` (after intake), `bash scripts/validate-plan.sh` (before implementation)
