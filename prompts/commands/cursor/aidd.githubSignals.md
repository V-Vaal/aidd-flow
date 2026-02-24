<!-- CURSOR-SPECIFIC: This file uses Cursor slash command syntax (@command).
     For IDE-agnostic equivalents, use the corresponding file in prompts/.
     Reference: prompts/start.md, prompts/intake.md, prompts/plan.md, etc. -->
# AIDD GitHub Signals Command

## Purpose

Fetch external signals from GitHub (issues and pull requests) using configuration-driven queries. Produces facts-only data for inclusion in AUDIT.md.

**Two distinct modes:**
- **Exploratory Mode**: General repository scan (issues/prs lists, minimal fields)
- **Targeted Mode**: Specific Issue/PR analysis (full context, keyword derivation, related context)

## Usage

1. **Read configuration**: Load `.cursor/work/github-signals.config.yml`
2. **Determine mode**: Check if `target` block exists (Targeted) or not (Exploratory)
3. **Fetch signals**: Use GitHub MCP to retrieve data according to mode
4. **Write artifact**: Create or update `.cursor/work/github-signals.md` with formatted results

## Procedure

### Step 0: Environment Preflight Check

**Purpose:** Detect available retrieval methods and log environment state explicitly.

**This step executes BEFORE any GitHub data retrieval** to provide transparency about execution environment.

**Detection Logic:**

1. **Check MCP GitHub availability (best-effort):**
   - Attempt to detect if GitHub MCP server is available
   - Method: Check if MCP tools for GitHub are accessible (best-effort check, may not be 100% reliable)
   - Result: `available` or `unavailable`
   - **Note:** This is a best-effort check; actual availability may be determined during execution

2. **Check gh CLI availability:**
   - Check if `gh` command exists: `command -v gh > /dev/null 2>&1`
   - Result: `available` or `unavailable`

3. **Check gh CLI authentication:**
   - If `gh` is available, check auth status: `gh auth status > /dev/null 2>&1`
   - Result: `authenticated` or `not authenticated` or `unknown` (if gh unavailable)

4. **Check GitHub token environment variables:**
   - Check for `GITHUB_TOKEN` environment variable: `[ -n "$GITHUB_TOKEN" ]`
   - Check for `GH_TOKEN` environment variable: `[ -n "$GH_TOKEN" ]`
   - Result: `present` (if either exists) or `missing` (if both absent)
   - **CRITICAL:** Never print token values, only check presence

5. **Determine planned retrieval method (priority order):**
   - **MCP** (if MCP GitHub available)
   - **gh** (if gh CLI available AND authenticated)
   - **REST** (if GITHUB_TOKEN or GH_TOKEN present)
   - **manual** (fallback, always available)

**Record environment state:**
- Store detection results for writing to github-signals.md in Step 4
- Store planned retrieval method
- Log to console: "Environment check: MCP={mcp_status}, gh={gh_status}, gh_auth={auth_status}, token={token_status}, planned_method={method}"

**Non-blocking behavior:**
- Never fail the run if MCP or env is missing
- Always proceed to next step regardless of environment state
- Make environment state explicit in logs and output

### Step 1: Read Configuration and Determine Mode

Read `.cursor/work/github-signals.config.yml` and extract:
- `repo`: Repository owner/name (e.g., `octocat/Hello-World`)
- `target`: Optional top-level block with `type` (issue|pr) and `number` for targeted retrieval
  - **If present**: Targeted Mode (fetch specific Issue/PR + Related Context)
  - **If absent**: Exploratory Mode (general repository scan)
- `issues`: Query parameters (state, labels_any, labels_all, exclude_labels, sort, limit)
- `prs`: Query parameters (state, labels_any, labels_all, exclude_labels, sort, limit)
- `context`: Optional block (only used in Targeted Mode) with:
  - `extract_references`: Boolean (default: true if target exists, false otherwise)
  - `search_keywords`: List of keywords for similar prior art search (default: empty)
  - `include_closed_issues_limit`: Integer (default: 10)
  - `include_merged_prs_limit`: Integer (default: 10)

**Mode determination:**
- **Targeted Mode**: `target` block exists at top-level
- **Exploratory Mode**: `target` block is absent

---

## MODE A: Exploratory Mode (General Repository Scan)

**When**: `target` block is absent from config

**Purpose**: Quick repository overview with minimal data collection

**Fields collected**: `id`, `title`, `state`, `labels`, `updated_at` only
**No deep context**: Body, comments, and related context are NOT collected

### Step 2A: Fetch Issues and PRs (Exploratory)

**If GitHub MCP is available:**
Use GitHub MCP tools to fetch data:

**For Issues:**
- Use MCP tool to list issues for the repository
- Apply filters from config:
  - Filter by `state` (open, closed, all)
  - Filter by labels (any/all/exclude as specified)
  - Sort by `sort` parameter (created, updated, comments)
  - Limit to `limit` number of results
- Extract fields: `id`, `title`, `state`, `labels`, `updated_at` only
- **Do NOT fetch**: body, comments, or other fields

**For Pull Requests:**
- Use MCP tool to list pull requests for the repository
- Apply filters from config:
  - Filter by `state` (open, closed, merged, all)
  - Filter by labels (any/all/exclude as specified)
  - Sort by `sort` parameter (created, updated, popularity)
  - Limit to `limit` number of results
- Extract fields: `id`, `title`, `state`, `labels`, `updated_at` only
- **Do NOT fetch**: body, comments, or other fields

**MCP Query Example:**
- Repository: Parse `repo` from config (format: `owner/name`)
- Build query filters based on config parameters
- Execute query via MCP
- Collect only specified fields (minimal data)

**If GitHub MCP is NOT available:**
- Proceed to Step 3A: Manual Fallback (Exploratory)

### Step 3A: Manual Fallback (Exploratory)

**If GitHub MCP is unavailable:**

Document in the command output that manual collection is required:
- User must manually visit GitHub repository
- Apply filters matching config parameters
- Copy-paste issue/PR data in the required format
- Same output format as MCP method

**Manual collection instructions:**
1. Navigate to `https://github.com/{owner}/{name}/issues`
2. Apply filters matching config (state, labels)
3. Sort by configured sort parameter
4. Collect up to `limit` items
5. For each item, extract: number, title, state, labels (comma-separated), updated_at
6. Repeat for pull requests at `https://github.com/{owner}/{name}/pulls`

**Output format**: Same as MCP method (minimal fields only)

**Proceed to Step 4A: Format Output (Exploratory)**

---

## MODE B: Targeted Mode (Specific Issue/PR Analysis)

**When**: `target` block exists at top-level in config

**Purpose**: Deep analysis of a specific Issue/PR with Related Context

**Fields collected**: Full context including body, comments, related issues/PRs
**Keyword derivation**: Automatic if `context.search_keywords` is empty
**Related Context**: Direct references, similar prior art, constraints/decisions

### Step 2B: Fetch Target Issue/PR (Targeted)

**If GitHub MCP is available:**

- Fetch the specific Issue/PR by number:
  - Use MCP tool to get issue/PR by number: `{repo}/{type}/{number}`
  - Extract fields: `id`, `title`, `state`, `labels`, `updated_at`
  - **Also fetch**: `body` and `comments` (required for keyword derivation and Related Context)
  - **Determine actual type**: Check if retrieved object is an Issue or PR (MCP response indicates type)
  - Record retrieval method as "MCP (targeted by number)"

**2B.1: Type Coherence Check (After Fetch)**

**After fetching target Issue/PR, verify type coherence:**

- **If actual type differs from config `target.type`:**
  - Actual type: Determined from MCP response (Issue vs PR)
  - Config type: `target.type` from config (issue vs pr)
  - **Auto-correct config:**
    - Update `.cursor/work/github-signals.config.yml`
    - Replace `target.type` with actual type (normalize: Issue → issue, PR → pr)
    - **YAML Writing Safety**: Replace entire line matching `^  type:\s*(issue|pr)$` (within `target:` block)
  - **Log correction:**
    - Console output: "Type corrected: config said '{config_type}', actual is '{actual_type}' (auto-corrected)"
    - Markdown output: Add note in github-signals.md header or Analysis Keywords section:
      ```markdown
      **Note:** Target type was auto-corrected from `{config_type}` to `{actual_type}` based on retrieved object.
      ```
- **If types match:**
  - No action needed, proceed normally

**If MCP cannot fetch by number:**
- Proceed to fallback (Step 3B) and record method as "manual (MCP unavailable for targeted retrieval)"
- Type coherence check will be skipped (cannot verify without fetched object)

**If GitHub MCP is NOT available:**
- Proceed to Step 3B: Fallback Methods (Targeted)

### Step 2.5: Derive Keywords (Targeted Mode Only)

**This step ALWAYS executes in Targeted Mode** (even if keywords are provided, to log them)

**Purpose:**
Derive analysis keywords from the target Issue/PR context. Keywords are an explicit analysis hypothesis and should be derived from the issue context, then frozen for the run.

**Deterministic Derivation Algorithm (if `context.search_keywords` is empty or missing):**

1. **Extract candidate keywords from target Issue/PR:**
   - **From title**: Split on whitespace/punctuation, extract:
     - Words with 3+ characters
     - Preserve CamelCase tokens as-is (e.g., `EASResolver` → `EASResolver`)
     - Lowercase common words for deduplication
   - **From labels**: Include all label names:
     - Convert to lowercase
     - Replace hyphens with underscores if needed
     - Preserve as-is (e.g., `bug-fix` → `bug_fix` or `bug-fix`)
   - **From body**: Extract identifiers using regex patterns:
     - CamelCase tokens: `[A-Z][a-zA-Z0-9]+` (e.g., `EASResolver`, `AttestationService`)
     - snake_case identifiers: `[a-z_]+[a-z0-9_]*` starting with underscore (e.g., `_attestationIds`, `_tokenId`)
     - Function-like tokens: `[a-z][a-zA-Z0-9]*\(` (e.g., `resolveAttestation(`, `get_attestation_id(`)
     - On-chain patterns: `tokenId`, `contractAddress`, `_attestationIds`
     - Technical terms (words with 4+ chars, exclude generic verbs)

2. **Filter generic words** (case-insensitive):
   - Generic verbs: `add`, `fix`, `update`, `should`, `improve`, `change`, `make`, `use`, `get`, `set`, `create`, `delete`, `remove`, `modify`
   - Generic nouns: `function`, `list`, `item`, `thing`, `stuff`, `code`, `file`, `method`, `class`
   - Common words: `the`, `a`, `an`, `is`, `are`, `was`, `were`, `be`, `been`, `have`, `has`, `had`, `do`, `does`, `did`, `will`, `would`, `could`, `should`

3. **Deduplication:**
   - Remove duplicates (case-insensitive for common words)
   - Preserve exact case for identifiers (CamelCase, snake_case)
   - Keep first occurrence

4. **Capping:**
   - Limit to **5-8 keywords maximum**
   - Prefer most specific/technical terms first
   - If more than 8 candidates, prioritize: identifiers > labels > technical terms > other words

5. **Write derived keywords to config:**
   - Update `.cursor/work/github-signals.config.yml`
   - Set `context.search_keywords` to the derived list (YAML array format)
   - **YAML Writing Safety**: Replace entire list (from `search_keywords:` to closing `]`), not inline concatenation
   - Preserve all other config fields (repo, target, issues, prs, context.*)
   - **CRITICAL**: This write must happen before Step 2.6 (Related Context search)
   - See `docs/workflow/github-signals.md#yaml-writing-safety` for safe YAML update patterns

6. **Record derivation in output:**
   - Log derived keywords (will be written to github-signals.md in Step 4B)
   - Mark as "Derived (auto)"

**If `context.search_keywords` is already non-empty:**
- **Skip derivation** (do not mutate provided keywords)
- Use provided keywords as-is
- Still record them in output as "Final (used)" (see Step 4B)
- Mark "Derived (auto)" as "skipped (keywords provided)"

**If GitHub MCP is NOT available:**
- Derivation can still be performed from the target Issue/PR data if it was fetched via REST API or gh CLI
- If target data is unavailable, document in output that manual keyword derivation is required

### Step 2.6: Collect Related Context (Targeted Mode Only)

**This step only executes if:**
- Config contains `target` block AND
- `context.extract_references` is true (or context block exists and extract_references is not explicitly false)

**If GitHub MCP is available:**

**2.6.1: Extract Direct References**

From the target Issue/PR body and comments, extract references using patterns (case-insensitive):
- `#123` → Issue/PR #123 in same repo (must be preceded by whitespace, start of line, or punctuation; not inside code blocks)
- `owner/repo#123` → Issue/PR #123 in owner/repo (same context rules)
- `https://github.com/owner/repo/issues/123` → Issue #123 (full URL)
- `https://github.com/owner/repo/pull/456` → PR #456 (full URL)
- `/pull/456` → PR #456 in same repo (must be in URL context)

**Extraction rules:**
- **Exclude false positives:**
  - Markdown headings: `## Heading #123` (the #123 is part of heading, not a reference)
  - Code blocks: References inside ```code blocks``` or `inline code` are ignored
  - URLs in markdown links: `[text](https://github.com/...)` should extract the URL, not the link text
- **Deduplication:**
  - If same issue/PR is referenced multiple times, include it only once
  - Prefer the first occurrence's context for relevance note
  - Track references by: `{repo}/{type}/{number}` (normalize owner/repo case)

For each unique reference found:
- Fetch the referenced Issue/PR via MCP (if available)
- Extract: `id`, `title`, `state`, `labels`, `updated_at`
- Record a one-line relevance note (e.g., "Referenced in target issue body" or "Mentioned in comment by @user")

**2.6.2: Search Similar Prior Art**

**Use the "Final (used)" keywords from Step 2.5:**
- If keywords were derived in Step 2.5, use those derived keywords
- If keywords were provided in config, use those provided keywords
- Keywords are now frozen for the rest of the run (no mutation after this point)

If `context.search_keywords` is non-empty:
- **Scope search to configured repo only** (do not search across all GitHub)
- Search closed issues matching keywords (limit: `context.include_closed_issues_limit`, enforced strictly)
- Search merged PRs matching keywords (limit: `context.include_merged_prs_limit`, enforced strictly)
- **Query refinement:**
  - Use AND logic for multiple keywords (all keywords must appear in title/body)
  - Exclude the target issue/PR itself from results
  - Prefer recent items (sort by updated_at descending)
- Extract: `id`, `title`, `state`, `labels`, `updated_at`
- Record relevance: "Matches keywords: [keyword1, keyword2]"
- **If no results found or limit reached:** Document this in output (empty list or "No similar issues/PRs found")

**If GitHub MCP is NOT available:**

**CRITICAL: Always produce the "Related Context" section structure, even in fallback mode.**

Provide manual collection instructions in the output:
- List patterns to search for in target issue/PR body and comments (same patterns as 2.5.1)
- Provide GitHub search URLs for similar issues/PRs (scoped to repo: `repo:owner/name`)
- **Output format MUST match MCP method (structured markdown with same section headings)**
- Include placeholder structure:
  ```markdown
  ## Related Context

  ### Direct References

  [Manual collection required: Search target issue/PR body and comments for patterns: #123, owner/repo#123, GitHub URLs]

  ### Similar Prior Art (Closed/Merged)

  [Manual collection required: Search https://github.com/{owner}/{name}/issues?q=is:closed+is:issue+{keywords}]

  ### Potential Constraints / Decisions

  [Manual collection required: Review referenced issues/PRs for constraints or decisions]
  ```

### Step 3B: Fallback Methods (Targeted Mode)

**If GitHub MCP is unavailable:**

**IMPORTANT: Failures at any step must NOT abort the command. Always write a complete github-signals.md file.**

1. **GitHub REST API (if available):**
   - Use `curl` with GitHub API endpoints
   - Requires `GITHUB_TOKEN` environment variable
   - Example: `curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/repos/{owner}/{name}/issues/{number}`
   - Fetch full Issue/PR data including body and comments
   - **Error handling:** If API call fails, log error but continue to next fallback method
   - **Rate limiting:** If rate limited, fall back to next method

2. **GitHub CLI (if `gh` command available):**
   - Use `gh issue view {number} --json body,comments` or `gh pr view {number} --json body,comments`
   - Fetch full Issue/PR data including body and comments
   - **Error handling:** If `gh` command fails or not authenticated, continue to manual instructions
   - Check `gh auth status` first; if not authenticated, skip to manual

3. **Manual Instructions (always available as final fallback):**
   - Output explicit step-by-step instructions matching the section structure
   - **Always produce the complete "Related Context" section structure** (even if empty or with manual instructions)
   - Ensure consistent github-signals.md format regardless of collection method
   - Never leave the Related Context section missing or incomplete
   - Include manual keyword derivation instructions if keywords were not derived

**After fallback:**
- If target Issue/PR data was successfully fetched, proceed to Step 2.5 (Derive Keywords) and Step 2.6 (Collect Related Context)
- If target data is unavailable, document manual steps required in output

---

### Step 4A: Format Output (Exploratory Mode)

Create `.cursor/work/github-signals.md` with:

**Header:**
```markdown
# GitHub Signals

**Query Configuration:** `.cursor/work/github-signals.config.yml`

**Repository:** {owner}/{name}

**Mode:** Exploratory (Repository scan)

**Retrieval Method:** [MCP | manual]
```

**Execution Environment (ALWAYS present):**

Insert here (after Header, before Query Parameters):

```markdown
## Execution Environment

- MCP GitHub: {available|unavailable}
- gh CLI: {available|unavailable}
- gh auth: {authenticated|not authenticated|unknown}
- GitHub token: {present|missing}
- Retrieval method (planned): {MCP|gh|REST|manual}
- Retrieval method (used): {MCP|gh|REST|manual}
```

**Notes:**
- This section is ALWAYS present in github-signals.md
- Values come from Step 0 (Environment Preflight Check)
- "Retrieval method (planned)" is determined in Step 0
- "Retrieval method (used)" is recorded after actual execution (update during Step 2A/2B or 3A/3B)
- If fallback occurs, log it: "MCP unavailable → falling back to gh CLI" (in console and markdown)

**Echo Query Config:**
```markdown
## Query Parameters

### Issues
- State: {state}
- Labels (any): {labels_any}
- Labels (all): {labels_all}
- Exclude labels: {exclude_labels}
- Sort: {sort}
- Limit: {limit}

### Pull Requests
- State: {state}
- Labels (any): {labels_any}
- Labels (all): {labels_all}
- Exclude labels: {exclude_labels}
- Sort: {sort}
- Limit: {limit}
```

**Results Summary:**
```markdown
## Results Summary

- Issues found: {count}
- Pull requests found: {count}
```

**Issues List:**
```markdown
## Issues

- #{id}: "{title}" {state} [{labels}] updated_at: {updated_at}
- #{id}: "{title}" {state} [{labels}] updated_at: {updated_at}
```

**Pull Requests List:**
```markdown
## Pull Requests

- #{id}: "{title}" {state} [{labels}] updated_at: {updated_at}
- #{id}: "{title}" {state} [{labels}] updated_at: {updated_at}
```

**Note:** Exploratory mode collects minimal fields only. For deep analysis of a specific Issue/PR, use Targeted mode (add `target` block to config).

---

### Step 4B: Format Output (Targeted Mode)

Create `.cursor/work/github-signals.md` with:

**Header:**
```markdown
# GitHub Signals

**Query Configuration:** `.cursor/work/github-signals.config.yml`

**Repository:** {owner}/{name}

**Mode:** Targeted (Issue/PR #{number})

**Retrieval Method:** [MCP | manual]

[If type was auto-corrected in Step 2B.1, add:]
**Note:** Target type was auto-corrected from `{config_type}` to `{actual_type}` based on retrieved object.
```

**Target Issue/PR:**
```markdown
## Target Issue/PR

- #{id}: "{title}" {state} [{labels}] updated_at: {updated_at}
```

**Echo Query Config:**
```markdown
## Query Parameters

### Issues
- State: {state}
- Labels (any): {labels_any}
- Labels (all): {labels_all}
- Exclude labels: {exclude_labels}
- Sort: {sort}
- Limit: {limit}

### Pull Requests
- State: {state}
- Labels (any): {labels_any}
- Labels (all): {labels_all}
- Exclude labels: {exclude_labels}
- Sort: {sort}
- Limit: {limit}
```

**Analysis Keywords (ALWAYS present in Targeted Mode):**

Insert here (after Query Parameters, before Results Summary):

```markdown
## Analysis Keywords

### Derived (auto)

[Only present if keywords were auto-derived in Step 2.5]
- {derived_keyword1}
- {derived_keyword2}
- {derived_keyword3}

[OR if keywords were provided:]
skipped (keywords provided)

### Final (used)

[Always present - shows keywords used for search]
- {final_keyword1}
- {final_keyword2}
- {final_keyword3}
```

**Results Summary:**
```markdown
## Results Summary

- Target Issue/PR: 1
- Issues found: {count}
- Pull requests found: {count}
```

**Issues List:**
```markdown
## Issues

- #{id}: "{title}" {state} [{labels}] updated_at: {updated_at}
- #{id}: "{title}" {state} [{labels}] updated_at: {updated_at}
```

**Pull Requests List:**
```markdown
## Pull Requests

- #{id}: "{title}" {state} [{labels}] updated_at: {updated_at}
- #{id}: "{title}" {state} [{labels}] updated_at: {updated_at}
```

**Related Context Section (ALWAYS present in Targeted Mode):**

Append after Pull Requests (even if empty or manual collection required):

```markdown
## Related Context

### Direct References

- #{id}: "{title}" {state} [{labels}] updated_at: {updated_at}
  - Relevance: {one-line note explaining why referenced}

### Similar Prior Art (Closed/Merged)

- #{id}: "{title}" closed [{labels}] updated_at: {updated_at}
  - Relevance: Matches keywords: [keyword1, keyword2]
- #{id}: "{title}" merged [{labels}] updated_at: {updated_at}
  - Relevance: Matches keywords: [keyword1, keyword2]

### Potential Constraints / Decisions

- {Bullet point describing constraint or decision}
  - {Source: "inferred from #123" or "quoted from comment by @user"}
- {Another constraint or decision}
  - {Source: "inferred from merged PR #456"}
```

**Format Rules:**
- Labels: comma-separated list in square brackets (e.g., `[bug,security]`)
- Updated_at: ISO 8601 format (e.g., `2024-01-15T10:30:00Z`)
- Related Context: Only included in targeted mode when context collection is enabled
- Constraints/Decisions: Mark "inferred" when not directly quoted from source
- Facts only: IDs, titles, state, labels, timestamps, relevance notes

## Output Format Examples

### Example 1: Targeted Mode

```markdown
# GitHub Signals

**Query Configuration:** `.cursor/work/github-signals.config.yml`

**Repository:** octocat/Hello-World

**Mode:** Targeted (Issue/PR #123)

**Retrieval Method:** MCP

## Execution Environment

- MCP GitHub: available
- gh CLI: available
- gh auth: authenticated
- GitHub token: present
- Retrieval method (planned): MCP
- Retrieval method (used): MCP

## Target Issue/PR

- #123: "Implement EAS attestation resolver" open [enhancement] updated_at: 2024-01-15T10:30:00Z

## Query Parameters

### Issues
- State: open
- Labels (any): [bug, security]
- Labels (all): []
- Exclude labels: [duplicate, wontfix]
- Sort: updated
- Limit: 20

### Pull Requests
- State: open
- Labels (any): [enhancement]
- Labels (all): []
- Exclude labels: [blocked]
- Sort: updated
- Limit: 10

## Analysis Keywords

### Derived (auto)

- eas
- resolver
- attestation
- schema
- migration

### Final (used)

- eas
- resolver
- attestation
- schema
- migration

## Results Summary

- Target Issue/PR: 1
- Issues found: 0
- Pull requests found: 0

## Issues

(No additional issues in this example)

## Pull Requests

(No additional PRs in this example)

## Related Context

### Direct References

- #456: "Related authentication fix" closed [bug] updated_at: 2024-01-10T08:00:00Z
  - Relevance: Referenced in target issue body

### Similar Prior Art (Closed/Merged)

- #234: "Previous schema migration" closed [migration] updated_at: 2024-01-05T12:00:00Z
  - Relevance: Matches keywords: [schema, migration]
- #567: "EAS resolver implementation" merged [enhancement] updated_at: 2024-01-08T14:30:00Z
  - Relevance: Matches keywords: [eas, resolver]

### Potential Constraints / Decisions

- Schema changes must maintain backward compatibility
  - Source: inferred from #234
- EAS resolver pattern should be reused when possible
  - Source: inferred from merged PR #567
```

### Example 2: Exploratory Mode

```markdown
# GitHub Signals

**Query Configuration:** `.cursor/work/github-signals.config.yml`

**Repository:** octocat/Hello-World

**Mode:** Exploratory (Repository scan)

**Retrieval Method:** MCP

## Query Parameters

### Issues
- State: open
- Labels (any): [bug, security]
- Labels (all): []
- Exclude labels: [duplicate, wontfix]
- Sort: updated
- Limit: 20

### Pull Requests
- State: open
- Labels (any): [enhancement]
- Labels (all): []
- Exclude labels: [blocked]
- Sort: updated
- Limit: 10

## Results Summary

- Issues found: 5
- Pull requests found: 3

## Issues

- #123: "Fix authentication bug" open [bug,security] updated_at: 2024-01-15T10:30:00Z
- #456: "SQL injection vulnerability" open [security,critical] updated_at: 2024-01-14T14:20:00Z

## Pull Requests

- #789: "Add rate limiting" open [enhancement] updated_at: 2024-01-16T09:15:00Z

**Note:** Exploratory mode collects minimal fields only. For deep analysis of a specific Issue/PR, use Targeted mode (add `target` block to config).
```

## Quick Reference

- **Config**: `.cursor/work/github-signals.config.yml`
- **Output**: `.cursor/work/github-signals.md`
- **Method**: GitHub MCP (preferred) or manual fallback
- **Fields**: id, title, state, labels, updated_at only
- **No interpretation**: Facts only, no analysis or recommendations

## Integration with AUDIT

This command produces data for the "External Signals (GitHub)" section in AUDIT.md:
- Copy query parameters and results summary to AUDIT.md
- Include issues and PRs lists in the required format
- Mark retrieval method (MCP or manual)
