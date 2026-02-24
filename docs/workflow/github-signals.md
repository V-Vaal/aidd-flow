# GitHub Signals

External signals collection for AUDIT using MCP, gh CLI, REST, or manual fallback.

## External Signals (GitHub)

**Mandatory rule**: AUDIT must include external signals from GitHub when applicable.

**Requirements:**
- Must be present in AUDIT.md when GitHub repository exists
- Facts only: IDs, titles, labels, state, updated_at
- No interpretation or prioritization
- No recommendations or action items
- Raw data presentation only

**Query-driven approach:**
- Must be driven by a human-defined query (config)
- Query defines what to fetch (issues, PRs, releases, etc.)
- Query parameters: repository, filters, date ranges, labels
- No automatic query generation

**Implementation:**
- GitHub MCP is preferred method
- Manual fallback is allowed (copy-paste from GitHub UI)
- Both methods must produce same fact-only format

**Format in AUDIT.md:**
- Section: "External Signals (GitHub)"
- List items with: ID, title, labels, state, updated_at
- No analysis or conclusions
- Example: `#123: "Fix authentication bug" [bug,security] open 2024-01-15`

## GitHub Signals (MCP / gh / REST fallbacks)

GitHub MCP (Model Context Protocol) is the preferred source for external signals during AUDIT. It provides structured, facts-only data from GitHub repositories without interpretation or analysis.

### Configuration-Driven Queries

**All queries are human-defined** via `aidd/work/github-signals.config.yml`. This ensures:
- Explicit control over what data is fetched
- No automatic query generation or assumptions
- Reproducible and auditable signal collection

### Facts-Only Output

MCP produces raw data only:
- Issue/PR IDs
- Titles
- Labels
- State (open, closed, merged)
- Updated timestamps

**No analysis, interpretation, prioritization, or recommendations.**

### Configuration Examples

**General query configuration:**
```yaml
repo: octocat/Hello-World

issues:
  state: open
  labels_any: [bug, security]
  labels_all: []
  exclude_labels: [duplicate, wontfix]
  sort: updated
  limit: 20

prs:
  state: open
  labels_any: [enhancement]
  labels_all: []
  exclude_labels: [blocked]
  sort: updated
  limit: 10
```

**Targeted retrieval (for specific Issue/PR):**
```yaml
repo: octocat/Hello-World

# Target block at top-level (canonical schema)
target:
  type: issue  # or "pr"
  number: 123

# Optional: keep existing issues/prs filters for additional context
issues:
  state: all
  limit: 10

# Related Context (Targeted Mode Only)
context:
  extract_references: true  # Extract direct references from target issue/PR
  search_keywords: [attestation, resolver, eas, schema, migration]  # Keywords for similar issues/PRs
  # If search_keywords is empty, keywords will be auto-derived from target Issue/PR
  # Derived keywords are written to config and recorded in github-signals.md
  include_closed_issues_limit: 10
  include_merged_prs_limit: 10
```

This configuration would fetch:
- The specific Issue/PR #123
- **Keywords**: If `search_keywords` is empty, auto-derives from target Issue/PR (title, labels, body, identifiers)
- Direct references found in issue/PR body and comments (#456, owner/repo#789, URLs)
- Up to 10 similar closed issues matching keywords
- Up to 10 similar merged PRs matching keywords
- Analysis keywords are recorded in github-signals.md under "## Analysis Keywords"
- Related context is appended to github-signals.md under "## Related Context"

### Output Format

**Standard format:**
```markdown
## External Signals (GitHub)

### Issues
- #123: "Fix authentication bug" [bug,security] open 2024-01-15T10:30:00Z
- #456: "SQL injection vulnerability" [security,critical] open 2024-01-14T14:20:00Z

### Pull Requests
- #789: "Add rate limiting" [enhancement] open 2024-01-16T09:15:00Z
```

**With Related Context (Targeted Mode):**
```markdown
## External Signals (GitHub)

### Execution Environment

- MCP GitHub: available
- gh CLI: available
- gh auth: authenticated
- GitHub token: present
- Retrieval method (planned): MCP
- Retrieval method (used): MCP

### Target Issue/PR
- #123: "Implement EAS attestation resolver" open [enhancement] updated_at: 2024-01-15T10:30:00Z

### Analysis Keywords

#### Derived (auto)
- eas
- resolver
- attestation
- schema

#### Final (used)
- eas
- resolver
- attestation
- schema

### Related Context

#### Direct References
- #456: "Previous schema migration" closed [migration] updated_at: 2024-01-10T08:00:00Z
  - Relevance: Referenced in target issue body

#### Similar Prior Art (Closed/Merged)
- #234: "EAS resolver implementation" merged [enhancement] updated_at: 2024-01-08T14:30:00Z
  - Relevance: Matches keywords: [eas, resolver]

#### Potential Constraints / Decisions
- Schema changes must maintain backward compatibility
  - Source: inferred from #456
```

**Analysis Keywords are automatically included in github-signals.md when:**
- Config contains `target` block AND
- Keywords were derived (if `search_keywords` was empty) or provided in config

**Related Context is automatically included in github-signals.md when:**
- Config contains `target` block AND
- `context.extract_references` is true (default for targeted mode)

### Rerun Semantics

When running Targeted mode multiple times:

**Target Reuse vs Override:**
- **If config already contains `target` block:**
  - **User provides new type/number**: Target is overridden
    - Old target replaced with new target
    - Logged: "Target overridden (was {old_type} #{old_number}, now {new_type} #{new_number})"
  - **User accepts default/empty**: Target is reused
    - Existing target kept unchanged
    - Logged: "Reusing existing target: {type} #{number}"
- **If config does NOT contain `target` block:**
  - User-provided type/number is used (new target created)

**Type Coherence:**
After fetching target Issue/PR:
- **If config type differs from actual type**: Auto-corrected
  - Config `target.type` updated to match actual type
  - Logged in console and `github-signals.md`: "Type corrected: config said '{config_type}', actual is '{actual_type}' (auto-corrected)"
- **If types match**: No action needed

### Keyword Derivation Details

Keywords are an explicit analysis hypothesis derived from the target Issue/PR context and frozen for the run.

**Auto-derivation process (when `search_keywords` is empty):**
1. Extract from target Issue/PR:
   - Title: meaningful words (nouns, technical terms)
   - Labels: all label names
   - Body: CamelCase tokens (contracts/classes), function names, on-chain IDs (e.g., `_attestationIds`)
2. Filter out generic verbs: add, fix, update, should, improve, change, make, use, get, set
3. Deduplicate (case-insensitive for common words, preserve exact case for identifiers)
4. Cap to 8 keywords maximum (prefer most specific/technical terms)
5. Write derived keywords to config (`context.search_keywords`)
6. Record in github-signals.md under "## Analysis Keywords" → "### Derived (auto)"

**Override:**
- To override auto-derivation, provide keywords in `context.search_keywords` before running the command
- Provided keywords are recorded as "### Final (used)" in github-signals.md

### Manual Fallback

If GitHub MCP is unavailable:
- User manually fills the "External Signals (GitHub)" section in AUDIT.md
- Same facts-only format required
- Copy-paste from GitHub UI is acceptable
- No difference in output format between MCP and manual methods
- **Environment state is still logged** in `github-signals.md` for transparency

## Environment Gate

The Environment Gate detects and logs the execution environment before GitHub signals retrieval. It prevents silent fallbacks and makes it clear which retrieval method is being used.

**Detection:**
- MCP GitHub availability (best-effort check)
- gh CLI availability: `command -v gh`
- gh CLI authentication: `gh auth status`
- GitHub token presence: `GITHUB_TOKEN` or `GH_TOKEN` environment variables

**Retrieval method priority:**
1. MCP (if MCP GitHub available)
2. gh (if gh CLI available AND authenticated)
3. REST (if `GITHUB_TOKEN` or `GH_TOKEN` present)
4. manual (fallback, always available)

**Output:**
Every `github-signals.md` includes an "Execution Environment" section:
```markdown
## Execution Environment

- MCP GitHub: available
- gh CLI: available
- gh auth: authenticated
- GitHub token: present
- Retrieval method (planned): MCP
- Retrieval method (used): MCP
```

**Environment setup:**
- Your AI agent inherits environment variables from the shell that launched it
- Dotenv files (`.env`) are NOT automatically loaded
- Export tokens before launching your IDE: `export GITHUB_TOKEN=your_token_here`
- Or use gh CLI: `gh auth login` (persists across sessions)

**Non-blocking behavior:**
- The Environment Gate never fails the run if MCP or env is missing
- Workflow always proceeds to next step
- Fallback methods are used automatically
- Environment state is logged explicitly for transparency

## Target Reset Gate

The Reset Gate prevents state contamination when switching between different targets in Targeted mode. It ensures deterministic behavior and clean artifact separation.

**Target identity:**
- Defined by: `repo|type|number` (e.g., `octocat/Hello-World|issue|123`)
- Persisted in `aidd/work/RUN_STATE.json` after each successful run

**Reset Gate logic:**
- **No previous run**: Proceed normally, create RUN_STATE.json after run
- **Same target**: Proceed normally, update RUN_STATE.json timestamp
- **Different target**: Trigger Reset Gate (automatic archive + reset)

**Reset Gate behavior:**
When target changes:
1. Creates archive folder: `aidd/work/_archive/{timestamp}-{repo}-{type}-{number}/`
2. Archives target-specific artifacts: TARGET.md, github-signals.md, AUDIT.md, INTAKE.md, PLAN.md, REVIEW.md, github-signals.config.yml (backup), RUN_STATE.json
3. Preserves non-target-specific files: CHECKLIST.md, DEBUG.md, PR.md, ARCHITECT_PACKET.md
4. Logs reset action in console
5. Proceeds with fresh run (all files written as fresh, not appended)

**File writing safety:**
All artifact files must be written as fresh files (overwrite, not append):
- Never concatenate or append to existing content
- Always write entire file
- Applies to: TARGET.md, github-signals.md, AUDIT.md, INTAKE.md, PLAN.md, REVIEW.md, RUN_STATE.json

## YAML Writing Safety

When updating `aidd/work/github-signals.config.yml`, always use full replacement patterns:

**Single-line values (e.g., `repo:`):**
- Use regex: `^repo:\s*.*$` to match entire line
- Replace entire matched line with new value
- If line doesn't exist, add it after header comments

**Block values (e.g., `target:`):**
- Identify block start: line matching `^target:\s*$`
- Identify block end: last line with 2-space indentation before next top-level key
- Replace all lines from start to end (inclusive)

**List values (e.g., `search_keywords:`):**
- Identify list start: line matching `^  search_keywords:\s*\[`
- Identify list end: line matching `^  \]` (or inline `[...]`)
- Replace entire list (single line if inline, multiple lines if expanded)

**Rules:**
- Always use full replacement, never inline concatenation
- Match entire lines/blocks using regex patterns
- Preserve indentation (2 spaces per level)
- Preserve other fields (only update target field/block)
- Handle missing fields (add if doesn't exist, don't fail)

## Keyword Derivation

In Targeted mode, when `context.search_keywords` is empty or missing, the workflow automatically derives 5-8 keywords from the target Issue/PR context.

**Derivation process:**
- Extracts from title, labels, and body
- Includes identifiers: CamelCase tokens, function names, on-chain IDs
- Filters out generic verbs: "add", "fix", "update", "should", "improve", "change", "make", "use", "get", "set"
- Limited to 8 keywords maximum
- Writes derived keywords to config and records them in `github-signals.md`

**Output:**
- Config updated: `context.search_keywords` contains derived list
- Markdown output: "## Analysis Keywords" section with "Derived (auto)" and "Final (used)" subsections

**Override:**
- If keywords are provided in config, derivation is skipped
- Provided keywords are used as-is for Related Context search
