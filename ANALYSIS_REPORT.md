# AIDD Protocol Alignment Analysis
**Repository:** aidd-flow-sandbox  
**Analysis Date:** 2026-01-28  
**Protocol Reference:** AIDD — Protocol Spec, Ideation Boundary & Tool-Agnostic Vision.md  
**Analyst:** Claude Sonnet 4.5

---

## 1. Executive Summary

### Overall Assessment

The `aidd-flow-sandbox` repository represents an **early-stage, Cursor-first implementation** of structured AI-assisted development. It demonstrates strong understanding of governance principles (gates, artifacts, human review) but exhibits **significant drift** from the target protocol vision defined in the normative document.

### Maturity Level

**Partial / Drifting**

- **Strengths**: Clear artifact structure (AUDIT, INTAKE, PLAN, REVIEW), validation gates, human review requirement
- **Weaknesses**: Tool coupling (Cursor-specific), missing ideation boundary, no role separation, implicit phase transitions
- **Gap**: The implementation focuses on Cursor-based execution workflow rather than tool-agnostic governance protocol

### Critical Finding

The repository conflates **"workflow implementation for Cursor"** with **"AIDD protocol"**. The protocol document defines AIDD as a tool-agnostic governance layer with explicit role separation, while the current implementation is a Cursor IDE workflow with embedded governance elements.

This is not a failure—it's a **valid implementation choice**—but it represents a fundamental architectural decision that must be acknowledged:

> Current state: **Cursor-first workflow with AIDD-inspired governance**  
> Protocol vision: **Tool-agnostic governance protocol with pluggable execution**

---

## 2. Strong Alignments

These elements demonstrate fidelity to protocol principles and should be preserved.

### 2.1 Artifact-Based Governance ✓

**Evidence:**
- `.cursor/work/AUDIT.md` structure exists
- `.cursor/work/INTAKE.md` with requirements and constraints
- `.cursor/work/PLAN.md` with validation gate (`validate-plan.sh`)
- `.cursor/work/REVIEW.md` with mandatory Verdict field

**Alignment:** The repository implements the canonical artifacts defined in protocol §§ Phase 1-5.

**Preservation priority:** HIGH. These artifacts encode the core governance model.

### 2.2 Validation Gates ✓

**Evidence:**
- `scripts/validate-plan.sh` checks PLAN.md structure before implementation
- `scripts/review-check.sh` validates REVIEW.md and Verdict field
- `.cursor/rules/00-master-workflow.mdc` enforces pre-flight and post-flight checks
- Exit-code based blocking (non-zero = stop workflow)

**Alignment:** Gates enforce explicit validation per protocol § Phase 4 (execution blocked without approved plan).

**Preservation priority:** HIGH. Gates are a fundamental invariant.

### 2.3 Human Review Authority ✓

**Evidence:**
- REVIEW.md requires explicit Verdict: `APPROVE | CHANGES_REQUESTED`
- `.cursor/rules/00-master-workflow.mdc` line 22: "No change is considered done without review approval"
- Definition of Done explicitly requires REVIEW.md with APPROVE verdict

**Alignment:** Human decision authority preserved per protocol § Fundamental Invariants #3.

**Preservation priority:** HIGH. Non-negotiable invariant.

### 2.4 Evidence-First Principle (Partial) ✓

**Evidence:**
- `docs/workflow.md` § Evidence-First Principle requires file path citations
- AUDIT.seed command enforces "do-not-invent policy" with citation requirements
- Skeptic Pass checklist verifies claims have evidence

**Alignment:** Matches protocol § Fundamental Invariants #1 (no context invention).

**Preservation priority:** HIGH. This is a core anti-hallucination mechanism.

**Gap:** Evidence requirement not enforced by tooling (validation scripts don't check citations).

### 2.5 External Signals Integration ✓

**Evidence:**
- `.cursor/commands/aidd.githubSignals.md` fetches GitHub data via MCP
- `github-signals.config.yml` provides query-driven signal collection
- Facts-only output format (no interpretation)

**Alignment:** Structured external input per protocol § Repository Scanning & Analysis Strategy.

**Preservation priority:** MEDIUM. Good pattern, but implementation is tightly coupled to GitHub/MCP.

---

## 3. Gaps & Ambiguities

These elements are absent, incomplete, or inconsistent with the protocol vision.

### 3.1 Missing Ideation Boundary ❌

**Protocol Requirement (§§ Pre-AIDD, Phase -1):**
> AIDD does not govern ideation. Before AIDD begins, there exists a free conceptual space where ideas are vague, hypotheses are fragile, contradictions are acceptable.

**Current State:**
- No `CONCEPT.md` or `IDEA.md` artifact exists
- No Phase -1 (Concept Freeze) in workflow
- `@aidd.start` is the entry point, but it assumes idea is already "ready"
- No mechanism to distinguish "free ideation" from "governed phases"

**Impact:** 
- Users enter AIDD directly without freezing conceptual assumptions
- Risk of scope creep (ideas evolve during execution without re-governance)
- Blurred boundary between exploration and commitment

**Evidence of gap:**
- `.cursor/prompts/start.md` has two modes: Targeted (Issue/PR) and Exploratory (Repo scan)
- Neither mode addresses "idea is not yet ready to be challenged"
- Protocol § Transition Point (line 72): "An idea enters AIDD only when an explicit decision is made"
- This decision gate is **not encoded** in current implementation

**Severity:** HIGH. This is a conceptual gap, not just a missing file.

### 3.2 Implicit Phase Transitions ❌

**Protocol Requirement (§ Fundamental Invariants #2):**
> Strict separation of phases. Audit ≠ Intake ≠ Plan ≠ Execution ≠ Review. No implicit transitions.

**Current State:**
- `.cursor/prompts/start.md` (Targeted mode) runs a sequence: `aidd.githubSignals → aidd.auditSeed → aidd.intake → aidd.plan → aidd.validate`
- This is a **script-driven cascade**, not explicit human-approved transitions
- No gate between Audit → Intake (user never approves "audit is sufficient, proceed to intake")
- No gate between Intake → Plan (user never explicitly says "intake is validated, create plan")

**Evidence:**
- `start.md` line 196-234: "Execute sequence" runs commands in order without human checkpoints
- `.cursor/rules/05-workflows-and-processes/5-aidd-loop.mdc` line 8: "Follow Intake → Plan → Implement → Verify → PR sequence" (procedural, not gate-based)

**Impact:**
- Phases blur together during execution
- User cannot pause between phases to reassess scope
- Violates protocol invariant #2

**Severity:** MEDIUM. Workflow is functional but violates strict phase separation.

### 3.3 Tool Coupling (Cursor-Specific) ❌

**Protocol Requirement (§ Tool-Agnostic Integration Rule):**
> Any tool integrated into AIDD must:
> 1. operate in a clearly identified role
> 2. produce or consume explicit artifacts
> 3. respect human validation gates
> 4. be replaceable without breaking the protocol

**Current State:**
- All commands are Cursor-specific: `.cursor/commands/aidd.*.md`
- Prompts assume Cursor Agent mode: `.cursor/prompts/`
- Rules use Cursor syntax: `.cursor/rules/*.mdc` with `globs`, `alwaysApply`
- GitHub signals use MCP (Cursor-specific Model Context Protocol)

**Evidence:**
- README.md line 24: "Cursor-first implementation"
- README.md line 48: "Optimized for Cursor, not designed for other IDEs"
- All workflow entry points use `@aidd.*` commands (Cursor syntax)

**Replaceability test:**
- **Cannot** use this workflow in VS Code, IntelliJ, or vim without rewriting commands
- **Cannot** replace Cursor Agent with ChatGPT without recreating prompt structure
- **Cannot** swap MCP for REST API without modifying githubSignals command

**Impact:**
- Protocol vision: tool-agnostic governance layer
- Current reality: Cursor IDE workflow with governance features
- This is **architectural drift**, not a bug

**Severity:** HIGH (conceptual), LOW (practical). The implementation is **honest** about being Cursor-first, but this diverges from protocol vision.

### 3.4 No Role Separation ❌

**Protocol Requirement (§ Cognitive Role Model):**
> AIDD defines roles, not tools:
> - A. Reasoning (abstraction, synthesis, contradiction detection)
> - B. Execution (apply plans, produce diffs)
> - C. Orchestration (sequence phases, enforce gates)
> - D. Workers (raw scans, extraction)

**Current State:**
- All roles performed by Cursor Agent (monolithic)
- No distinction between "reasoning" (audit, plan analysis) and "execution" (code changes)
- No orchestration layer (user manually runs commands)
- No worker delegation (Cursor does everything)

**Evidence:**
- `.cursor/commands/aidd.audit.md` → Cursor performs reasoning (audit analysis)
- `.cursor/commands/aidd.plan.md` → Cursor performs reasoning (plan creation)
- Implementation (implicit) → Cursor performs execution (code diffs)
- No separate "orchestrator" process (user runs `@aidd.start` manually)

**Protocol expectation (§ Orchestration — "The Conductor"):**
> Typical tools: LangGraph, scripts, task runners

**Current reality:**
- User is the orchestrator (manual command execution)
- No programmatic orchestration
- No swarm/multi-agent coordination

**Impact:**
- Cannot delegate reasoning to Claude UI while using Cursor for execution
- Cannot parallelize tasks across specialized agents
- Violates protocol § Cognitive Role Model separation

**Severity:** HIGH. This is a fundamental architectural gap.

### 3.5 Ambiguous Entry Point (aidd.start) ⚠️

**Protocol Requirement (§ Phase 0 — Entry Point):**
> Defines why an AIDD cycle exists. Modes:
> - Targeted audit (Issue / PR / specific objective)
> - Exploratory audit (repository or concept analysis)

**Current State:**
- `@aidd.start` has two modes: Targeted (Issue/PR) and Exploratory (Repo scan)
- **Targeted mode** assumes GitHub Issue/PR exists (external trigger)
- **Exploratory mode** assumes repository exists (analysis trigger)
- **Missing:** "Concept" mode (idea is not yet in GitHub, not yet committed)

**Evidence:**
- `.cursor/prompts/start.md` line 10-18: Mode selection between A (Targeted) and B (Exploratory)
- No option for "C) Concept validation" or "C) Idea is not ready for audit"

**Gap:**
- Protocol § Pre-AIDD (line 44): "Before AIDD begins, there exists a free conceptual space"
- Protocol § Phase -1 (line 87): "CONCEPT.md (or IDEA.md)" artifact
- Current `@aidd.start` skips this phase entirely

**Impact:**
- User cannot enter AIDD with "just an idea"
- Forces premature concretization (must create GitHub Issue to use Targeted mode)
- Blurs boundary between ideation and governance

**Severity:** MEDIUM. This is a missing mode, not a broken implementation.

### 3.6 No Explicit Human Authority Gates ⚠️

**Protocol Requirement (§ Fundamental Invariants #3, #4):**
> - AI must never decide, approve, or conclude
> - Each phase transition requires explicit validation, acknowledgment of risks

**Current State:**
- Validation scripts check **structure**, not **approval**
- `validate-plan.sh` verifies PLAN.md has required sections (structural check)
- No mechanism to record "human reviewed and approved PLAN.md"
- REVIEW.md Verdict is the **only** explicit approval gate

**Evidence:**
- `validate-plan.sh` checks for sections (Goal, Scope, Steps, etc.) but does not check for "APPROVED" status field
- `.cursor/work/PLAN.md` has no status field (DRAFT / REVIEWED / APPROVED)
- `docs/workflow.md` line 90 mentions "Artefact Statuses" (DRAFT / REVIEWED / APPROVED) but this is **not implemented** in artifacts or validation

**Gap:**
- AI could generate AUDIT.md, INTAKE.md, PLAN.md in sequence without human pause
- Only REVIEW.md has explicit human Verdict field
- Intermediate artifacts lack approval mechanism

**Impact:**
- User might proceed to implementation without explicitly approving PLAN
- Violates protocol requirement for "explicit gates" at each phase transition

**Severity:** MEDIUM. The workflow assumes human oversight but doesn't enforce it.

### 3.7 No Concept of "Tool-Agnostic Artifacts" ⚠️

**Protocol Requirement (§ Tool-Agnostic Integration Rule):**
> Any tool must produce or consume explicit artifacts. Artifacts should be tool-neutral (Markdown, YAML, JSON).

**Current State:**
- Artifacts are Markdown (good: tool-neutral format)
- But: Artifacts are stored in `.cursor/work/` (Cursor-specific location)
- But: Commands reference artifacts using Cursor paths (`.cursor/work/PLAN.md`)
- But: Prompts assume Cursor Agent context (cannot be used in ChatGPT without editing)

**Evidence:**
- All artifacts in `.cursor/work/` directory (Cursor namespace)
- `.cursor/commands/aidd.plan.md` line 17: "Creates or updates: `.cursor/work/PLAN.md`"
- Prompts use Cursor-specific syntax: `@aidd.start`, `@aidd.plan`, etc.

**Protocol expectation:**
- Artifacts should be in workspace root or neutral location (`/AIDD/`, `/docs/aidd/`, etc.)
- Commands should reference artifacts by **role**, not path (e.g., "read the Plan artifact")
- Prompts should be tool-agnostic (usable in any chat interface)

**Impact:**
- Artifacts are conceptually tool-neutral (Markdown) but operationally tool-coupled (Cursor paths)
- Cannot easily use artifacts with other tools without path translation

**Severity:** LOW. This is a cosmetic issue, not a fundamental gap.

---

## 4. Structural vs Conceptual Issues

Classification of findings by nature and remediation strategy.

### 4.1 Conceptual Issues (Protocol Not Yet Encoded)

These gaps require **design decisions** and **protocol clarification**, not just file creation.

| Issue | Protocol Requirement | Current Gap | Remediation Complexity |
|-------|---------------------|-------------|------------------------|
| **Missing Ideation Boundary** | Pre-AIDD space, CONCEPT.md | No Phase -1, no concept artifact | HIGH — requires defining transition criteria from "idea" to "AIDD entry" |
| **No Role Separation** | Reasoning/Execution/Orchestration roles | Monolithic Cursor Agent | HIGH — requires multi-tool architecture or explicit role delegation within Cursor |
| **Implicit Phase Transitions** | Explicit gates at each phase boundary | Script-driven cascade | MEDIUM — requires adding approval gates between phases |
| **No Human Authority Mechanism** | Explicit approval, not just validation | Structural validation only | MEDIUM — requires adding "APPROVED" status fields to artifacts |
| **Tool Coupling** | Tool-agnostic artifacts and roles | Cursor-first implementation | HIGH — fundamental architectural choice (Cursor-first vs protocol-first) |

**Recommendation:** Address these in **design phase**, not implementation. They require clarifying **what AIDD is** (protocol or workflow).

### 4.2 Structural Issues (Repo Layout, Missing Files)

These gaps are **mechanical** and can be addressed by adding files or reorganizing directories.

| Issue | Missing Element | Impact | Remediation Complexity |
|-------|-----------------|--------|------------------------|
| **No CONCEPT.md template** | `.cursor/work/CONCEPT.md` template | Users cannot freeze ideas before AIDD | LOW — create template, add to start.md |
| **No artifact status tracking** | DRAFT/REVIEWED/APPROVED status fields in artifacts | Cannot distinguish "AI-generated" from "human-approved" | LOW — add status field to artifact templates |
| **No orchestration layer** | Separate orchestrator script or service | User must manually run commands | MEDIUM — create orchestration script (e.g., `aidd-orchestrate.sh`) |
| **Cursor-specific artifact paths** | `.cursor/work/` → tool-neutral location | Artifacts coupled to Cursor directory structure | LOW — move to neutral location (e.g., `.aidd/work/`) |

**Recommendation:** These can be incrementally addressed **without breaking existing workflow**.

### 4.3 Tooling Issues (Scripts, Assumptions, Coupling)

These gaps are **implementation-specific** and can be fixed by improving scripts or adding adapters.

| Issue | Current Limitation | Impact | Remediation Complexity |
|-------|-------------------|--------|------------------------|
| **MCP GitHub coupling** | GitHub signals via MCP only | Cannot use workflow without MCP or GitHub | LOW — already has fallback to gh CLI, REST API |
| **No evidence validation** | Evidence-first principle not enforced by tooling | Users can create artifacts without citations | MEDIUM — add citation checker to validation scripts |
| **No inter-tool adapters** | Cannot use PLAN.md generated in ChatGPT with Cursor execution | Workflow locked to single tool | HIGH — requires adapter layer or standard artifact schema |
| **Manual orchestration** | User runs commands manually (`@aidd.start`, `@aidd.plan`) | No automated workflow progression | MEDIUM — create orchestration script or task runner |

**Recommendation:** Prioritize evidence validation and orchestration automation. Inter-tool adapters are lower priority (architectural).

---

## 5. Roadmap Toward Convergence

Progressive evolution path from current state to protocol vision. **No rewrites. Minimal disruption. Clear priorities.**

### Principle: Dual-Track Evolution

The roadmap assumes **two parallel tracks** that can be developed independently:

1. **Track A: Cursor-First Workflow** (preserve current implementation, improve governance)
2. **Track B: Protocol-First Architecture** (build tool-agnostic layer on top)

Track A is **immediate** (incremental improvements to existing workflow).  
Track B is **strategic** (long-term convergence toward protocol vision).

---

### Phase 1: Strengthen Current Workflow (Cursor-First Track)

**Goal:** Improve governance and validation in existing Cursor-first implementation without breaking changes.

**Duration:** 2-4 weeks (if working full-time)

#### 1.1 Add Concept Phase (Missing Ideation Boundary)

**Action:**
- Create `.cursor/work/CONCEPT.md` template (per protocol § Phase -1)
- Add "Concept Mode" to `@aidd.start`:
  - Mode C: Concept validation (idea not yet in GitHub, not yet committed)
  - Prompt: "Freeze initial intuition, perceived problem, assumptions, known unknowns"
- Update `start.md` to include Concept → Audit transition gate

**Success Criteria:**
- User can enter AIDD with "just an idea" (no GitHub Issue required)
- CONCEPT.md artifact freezes assumptions before audit
- Clear boundary between "free ideation" (pre-CONCEPT) and "governed phases" (post-CONCEPT)

**Effort:** LOW (1-2 days)

#### 1.2 Add Explicit Approval Gates (Phase Transitions)

**Action:**
- Add "APPROVAL STATUS" field to AUDIT.md, INTAKE.md, PLAN.md templates:
  ```markdown
  **Status:** DRAFT | REVIEWED | APPROVED
  ```
- Update validation scripts to check status field:
  - `validate-plan.sh` → fail if PLAN.md status is not APPROVED
  - Create `validate-intake.sh` → fail if INTAKE.md status is not APPROVED
- Update `start.md` cascade to pause between phases:
  - After AUDIT.md created → prompt user: "Review AUDIT.md. Set status to APPROVED when ready."
  - After INTAKE.md created → prompt user: "Review INTAKE.md. Set status to APPROVED when ready."
  - After PLAN.md created → prompt user: "Review PLAN.md. Set status to APPROVED when ready."

**Success Criteria:**
- User must explicitly set "APPROVED" status before next phase
- Validation scripts enforce approval requirement
- No implicit phase transitions (cascade stops at each gate)

**Effort:** MEDIUM (2-3 days)

#### 1.3 Enforce Evidence-First Principle (Citation Validation)

**Action:**
- Create `validate-evidence.sh` script:
  - Scan AUDIT.md, INTAKE.md, PLAN.md for claims without citations
  - Flag claims that lack file paths, line numbers, or command outputs
  - Fail if evidence violations exceed threshold (e.g., >5 uncited claims)
- Integrate into `aidd-check.sh` as optional flag: `--evidence`
- Add citation guide to `docs/workflow.md` § Evidence Format

**Success Criteria:**
- Validation scripts detect uncited claims
- User receives actionable feedback: "Claim on line 45 has no citation. Add file path or command output."
- Evidence-first principle is **enforced**, not just recommended

**Effort:** MEDIUM (3-4 days)

#### 1.4 Improve Orchestration (Reduce Manual Steps)

**Action:**
- Create `scripts/aidd-orchestrate.sh`:
  - Runs full workflow sequence with human checkpoints
  - Pauses at each phase transition for user approval
  - Validates artifacts before proceeding
  - Logs workflow state to `.cursor/work/WORKFLOW_STATE.json`
- Example:
  ```bash
  bash scripts/aidd-orchestrate.sh --mode targeted --issue 123
  # → Fetches GitHub signals
  # → Creates AUDIT.md (DRAFT)
  # → Prompts: "Review AUDIT.md. Type 'approve' to continue."
  # → User types 'approve' → sets status to APPROVED
  # → Creates INTAKE.md (DRAFT)
  # → Prompts: "Review INTAKE.md. Type 'approve' to continue."
  # → Repeat until REVIEW.md
  ```

**Success Criteria:**
- User runs single command to initiate full workflow
- Workflow pauses at each gate for explicit approval
- Reduces manual `@aidd.*` command invocation

**Effort:** MEDIUM (3-5 days)

**Phase 1 Summary:**
- **Total effort:** 9-14 days
- **Impact:** Strengthens governance without breaking existing Cursor-first workflow
- **Deliverables:** CONCEPT.md, approval gates, evidence validation, orchestration script

---

### Phase 2: Separate Reasoning from Execution (Role Clarity)

**Goal:** Introduce explicit role separation within Cursor-first workflow as preparation for multi-tool architecture.

**Duration:** 2-3 weeks

#### 2.1 Document Role Boundaries (Conceptual Clarity)

**Action:**
- Create `docs/roles.md`:
  - Define Reasoning role (Cursor for audit, plan analysis)
  - Define Execution role (Cursor for code diffs, tests)
  - Define Orchestration role (scripts or user)
  - Define Worker role (local models or scripts for scans)
- Update `.cursor/commands/` to annotate role:
  ```markdown
  # AIDD Audit Command
  **Role:** Reasoning (abstraction, synthesis, contradiction detection)
  ```

**Success Criteria:**
- User understands which commands are "reasoning" vs "execution"
- Documentation clarifies that Cursor currently performs multiple roles (acknowledged, not fixed)

**Effort:** LOW (1-2 days)

#### 2.2 Extract Worker Tasks (Preparation for Delegation)

**Action:**
- Identify tasks that **could** be delegated to local models or scripts:
  - `aidd.auditSeed` → factual repository scan (Worker role)
  - `aidd.githubSignals` → data extraction (Worker role)
  - Evidence validation → citation checker (Worker role)
- Create parallel implementations using local tools:
  - `scripts/scan-repo.sh` → uses `tree`, `grep`, `wc` to generate repository summary
  - `scripts/check-citations.sh` → regex-based citation validator
- Make these **optional alternatives** (not replacements):
  - User can choose: Cursor (`@aidd.auditSeed`) or script (`bash scripts/scan-repo.sh`)

**Success Criteria:**
- Proof of concept: some tasks can be done without Cursor
- User has choice between Cursor-native and script-based implementations
- Prepares for future multi-tool architecture

**Effort:** MEDIUM (4-6 days)

#### 2.3 Prototype External Reasoning (ChatGPT Integration)

**Action:**
- Export AUDIT.md, INTAKE.md, PLAN.md to **portable format** (already Markdown, no change needed)
- Create `docs/using-chatgpt.md`:
  - Guide: "How to use ChatGPT for reasoning while using Cursor for execution"
  - Example workflow:
    1. Export AUDIT.md, INTAKE.md to ChatGPT UI
    2. Ask ChatGPT: "Review this audit. What risks are missing?"
    3. Manually incorporate ChatGPT feedback into artifacts
    4. Continue execution in Cursor
- Test workflow with real example (document findings)

**Success Criteria:**
- User can successfully use ChatGPT for reasoning and Cursor for execution
- Identifies gaps in artifact portability (e.g., Cursor-specific references)
- Documents manual integration steps

**Effort:** LOW (2-3 days)

**Phase 2 Summary:**
- **Total effort:** 7-11 days
- **Impact:** Introduces role separation conceptually, prepares for multi-tool architecture
- **Deliverables:** Role documentation, worker task scripts, ChatGPT integration guide

---

### Phase 3: Tool-Agnostic Artifact Layer (Protocol Convergence)

**Goal:** Decouple artifacts from Cursor-specific paths and syntax, enabling use with other tools.

**Duration:** 3-4 weeks

#### 3.1 Migrate to Neutral Artifact Location

**Action:**
- Move artifacts from `.cursor/work/` to `.aidd/work/` (tool-neutral namespace)
- Update all scripts and commands to reference `.aidd/work/` instead of `.cursor/work/`
- Keep `.cursor/` for Cursor-specific configs (commands, prompts, rules)
- Add symlink for backwards compatibility: `.cursor/work/` → `.aidd/work/`

**Success Criteria:**
- Artifacts are stored in tool-neutral location
- Scripts work with both `.cursor/work/` (legacy) and `.aidd/work/` (new)
- Other tools can reference `.aidd/work/PLAN.md` without assuming Cursor

**Effort:** MEDIUM (3-5 days)

#### 3.2 Create Tool-Agnostic Command Wrappers

**Action:**
- Create `scripts/aidd-audit.sh`, `scripts/aidd-plan.sh`, etc. as tool-agnostic entry points
- These scripts:
  - Check if `.cursor/` exists → call Cursor-specific command (`@aidd.audit`)
  - If not → fall back to manual prompt: "Run the Audit phase using your preferred tool (ChatGPT, Claude, etc.). Reference `.aidd/prompts/audit.md`."
- Move prompts to `.aidd/prompts/` (neutral location, no Cursor syntax)

**Success Criteria:**
- User can run `bash scripts/aidd-audit.sh` regardless of tool
- Scripts provide fallback instructions for non-Cursor environments
- Prompts are tool-agnostic (no `@` syntax)

**Effort:** MEDIUM (4-6 days)

#### 3.3 Define Artifact Interchange Format (Schema)

**Action:**
- Create `.aidd/schemas/` directory with JSON schemas for artifacts:
  - `AUDIT.schema.json` → defines required sections, field types
  - `PLAN.schema.json` → defines Steps, Files, Tests structure
  - `REVIEW.schema.json` → defines Verdict, Test Evidence structure
- Update validation scripts to validate against schemas (optional: use `ajv` or similar)
- Add metadata to artifacts (for tool interoperability):
  ```yaml
  ---
  schema_version: "1.0"
  generated_by: "cursor-agent"
  generated_at: "2026-01-28T10:30:00Z"
  ---
  ```

**Success Criteria:**
- Artifacts have machine-readable schemas
- Tools can validate artifacts without assuming Cursor-specific structure
- Prepares for future tool adapters (e.g., PLAN.md generated in ChatGPT, consumed by Cursor)

**Effort:** HIGH (5-7 days)

#### 3.4 Prototype Multi-Tool Workflow

**Action:**
- Test workflow using multiple tools:
  - Reasoning: Claude UI (web interface)
  - Execution: Cursor Agent
  - Orchestration: `scripts/aidd-orchestrate.sh`
  - Workers: Local scripts (`scan-repo.sh`, `check-citations.sh`)
- Document integration points and friction:
  - Where does artifact handoff break?
  - What manual steps are required?
  - What adapters are needed?

**Success Criteria:**
- Proof of concept: PLAN.md created in Claude UI can be consumed by Cursor for execution
- Document gaps and required adapters
- Validate protocol assumption: "tools are replaceable"

**Effort:** MEDIUM (3-5 days)

**Phase 3 Summary:**
- **Total effort:** 15-23 days
- **Impact:** Artifacts become tool-agnostic, enabling multi-tool workflows
- **Deliverables:** Neutral artifact location, tool-agnostic scripts, schemas, multi-tool proof of concept

---

### Phase 4: Orchestration Layer (Protocol Compliance)

**Goal:** Implement protocol-compliant orchestration with explicit role delegation and phase gates.

**Duration:** 4-6 weeks

#### 4.1 Design Orchestration Architecture

**Action:**
- Define orchestration requirements per protocol § Orchestration role:
  - Sequence phases (Concept → Audit → Intake → Plan → Execution → Review)
  - Enforce gates (block progression until approval)
  - Route artifacts (pass AUDIT.md to Intake phase, INTAKE.md to Plan phase)
  - Manage controlled loops (re-run phases if validation fails)
- Choose orchestration tool:
  - **Option A:** LangGraph (protocol suggestion, requires Python)
  - **Option B:** Shell scripts with state machine (`aidd-orchestrate.sh` enhanced)
  - **Option C:** Task runner (e.g., `make`, `just`, `cargo-make`)

**Success Criteria:**
- Orchestration architecture documented
- Tool choice justified (trade-offs documented)
- Implementation plan created

**Effort:** LOW (2-3 days, design only)

#### 4.2 Implement Orchestration State Machine

**Action:**
- Implement orchestration logic:
  - State tracking: `.aidd/work/WORKFLOW_STATE.json` records current phase, approvals, artifacts
  - Phase transitions: Orchestrator checks gates before advancing
  - Human approval: Orchestrator prompts for explicit approval (CLI or UI)
  - Error handling: Orchestrator retries failed phases or escalates to user
- Example state machine:
  ```
  IDLE → [user: start concept] → CONCEPT_DRAFT
  CONCEPT_DRAFT → [user: approve] → CONCEPT_APPROVED
  CONCEPT_APPROVED → [orchestrator: run audit] → AUDIT_DRAFT
  AUDIT_DRAFT → [user: approve] → AUDIT_APPROVED
  AUDIT_APPROVED → [orchestrator: run intake] → INTAKE_DRAFT
  ... (continue for all phases)
  ```

**Success Criteria:**
- Orchestrator runs full workflow without user manually invoking commands
- User only provides approvals at gates (no command memorization)
- State is persisted (workflow can resume after interruption)

**Effort:** HIGH (7-10 days)

#### 4.3 Integrate Role Delegation

**Action:**
- Orchestrator delegates tasks to appropriate tools based on role:
  - **Reasoning tasks** → route to high-capability model (Claude, ChatGPT)
  - **Execution tasks** → route to IDE agent (Cursor, Claude Code)
  - **Worker tasks** → route to local scripts or models (Ollama, grep)
- Orchestrator configuration: `.aidd/orchestrator.yml`:
  ```yaml
  roles:
    reasoning:
      tool: "claude-ui"  # or "chatgpt", "cursor"
      tasks: ["audit", "intake", "plan"]
    execution:
      tool: "cursor"
      tasks: ["implement", "test"]
    workers:
      tool: "scripts"
      tasks: ["scan-repo", "validate-evidence"]
  ```

**Success Criteria:**
- Orchestrator can delegate tasks to different tools
- User configures tool assignments in `.aidd/orchestrator.yml`
- Proof: Run audit in Claude UI, execution in Cursor, all via orchestrator

**Effort:** HIGH (8-12 days)

#### 4.4 Add Swarm / Parallel Task Support (Optional)

**Action:**
- Extend orchestrator to support parallel task execution:
  - Example: Audit can run `scan-repo.sh` (Worker) and `fetch-github-signals.sh` (Worker) in parallel
  - Orchestrator aggregates outputs into AUDIT.md
- Use task runner (e.g., `parallel`, `xargs`, or LangGraph's parallelization)

**Success Criteria:**
- Orchestrator can run independent tasks in parallel
- Workflow time reduced (e.g., audit completes 2x faster)
- Proof: Audit phase completes in 30s instead of 60s

**Effort:** MEDIUM (3-5 days, optional)

**Phase 4 Summary:**
- **Total effort:** 20-30 days
- **Impact:** Full protocol-compliant orchestration with role delegation
- **Deliverables:** Orchestrator state machine, role delegation, parallel task support

---

### Phase 5: Polish & Documentation (Maturity)

**Goal:** Document converged architecture, add examples, prepare for external adoption.

**Duration:** 2-3 weeks

#### 5.1 Update Documentation

**Action:**
- Rewrite README.md to reflect new architecture:
  - "AIDD is a tool-agnostic protocol" (not "Cursor-first workflow")
  - "This repository provides reference implementation and orchestration scripts"
  - Document role separation (Reasoning, Execution, Orchestration, Workers)
- Update `docs/workflow.md` to reflect orchestrated workflow (not manual commands)
- Create `docs/architecture.md`:
  - Diagram: Protocol layers (Conceptual, Governance, Orchestration, Tools)
  - Explain artifact flow
  - Document tool integration points

**Success Criteria:**
- Documentation accurately reflects protocol vision
- New users understand AIDD as protocol, not Cursor workflow
- Clear distinction between "reference implementation" and "protocol specification"

**Effort:** MEDIUM (4-6 days)

#### 5.2 Add Examples and Tutorials

**Action:**
- Create `examples/` directory:
  - `examples/simple-feature/` → walk through full AIDD cycle (Concept → Review)
  - `examples/multi-tool/` → demonstrate using Claude UI for reasoning, Cursor for execution
  - `examples/bug-fix/` → show Exploratory → Targeted conversion
- Record video walkthrough (optional, high impact)

**Success Criteria:**
- New users can follow example and complete AIDD cycle
- Examples demonstrate protocol principles (role separation, gates, evidence)

**Effort:** MEDIUM (3-5 days)

#### 5.3 Add Migration Guide (Cursor-First → Protocol)

**Action:**
- Create `docs/migration.md`:
  - Guide existing users from current Cursor-first workflow to new orchestrated workflow
  - Document breaking changes (e.g., `.cursor/work/` → `.aidd/work/`)
  - Provide migration script: `bash scripts/migrate-to-v2.sh`

**Success Criteria:**
- Existing users can migrate without data loss
- Breaking changes are documented
- Migration script handles common cases (symlinks, path updates)

**Effort:** LOW (2-3 days)

#### 5.4 Validate Protocol Compliance

**Action:**
- Create `scripts/validate-protocol.sh`:
  - Check repository against protocol requirements:
    - ✓ CONCEPT.md exists
    - ✓ Explicit gates at each phase
    - ✓ Artifacts are tool-agnostic
    - ✓ Role separation documented
    - ✓ Evidence-first enforced
  - Output compliance report
- Run validation against repository:
  ```bash
  bash scripts/validate-protocol.sh
  # → Protocol Compliance Report
  # → ✓ Ideation boundary: CONCEPT.md template exists
  # → ✓ Phase separation: explicit gates enforced
  # → ✓ Tool-agnostic: artifacts in .aidd/work/
  # → ✓ Role separation: documented in docs/roles.md
  # → ⚠ Orchestration: partial (manual fallback required)
  # → Overall: 95% compliant
  ```

**Success Criteria:**
- Repository achieves >90% protocol compliance
- Remaining gaps are documented as "acceptable deviations" or "future work"

**Effort:** MEDIUM (3-4 days)

**Phase 5 Summary:**
- **Total effort:** 12-18 days
- **Impact:** Repository is polished, documented, and protocol-compliant
- **Deliverables:** Updated docs, examples, migration guide, protocol validation script

---

## Roadmap Summary

| Phase | Goal | Effort (days) | Cumulative | Priority |
|-------|------|---------------|------------|----------|
| **Phase 1** | Strengthen current workflow (approval gates, evidence validation, orchestration) | 9-14 | 9-14 | HIGH |
| **Phase 2** | Separate reasoning from execution (role clarity, worker delegation) | 7-11 | 16-25 | MEDIUM |
| **Phase 3** | Tool-agnostic artifact layer (neutral paths, schemas, multi-tool proof) | 15-23 | 31-48 | HIGH |
| **Phase 4** | Orchestration layer (state machine, role delegation, parallel tasks) | 20-30 | 51-78 | MEDIUM |
| **Phase 5** | Polish & documentation (examples, migration guide, protocol validation) | 12-18 | 63-96 | LOW |

**Total estimated effort:** 63-96 days (3-4.5 months full-time equivalent)

**Minimal viable convergence (Phases 1 + 3):** 24-37 days (1-2 months)

---

## Key Trade-Offs & Decisions

### Trade-Off 1: Cursor-First vs Protocol-First

**Current State:** Cursor-first implementation with governance features  
**Protocol Vision:** Tool-agnostic protocol with pluggable execution

**Options:**

**A. Preserve Cursor-First (Status Quo)**
- **Pros:** Works today, no breaking changes, familiar to users
- **Cons:** Violates protocol vision, tool-locked, cannot use other tools
- **Recommendation:** Short-term preservation is acceptable **if documented** as "reference implementation for Cursor"

**B. Refactor to Protocol-First**
- **Pros:** Full protocol compliance, tool-agnostic, future-proof
- **Cons:** High effort (Phases 3-4), breaking changes, learning curve
- **Recommendation:** Long-term goal, phased migration (roadmap above)

**C. Hybrid Approach (Dual-Track)**
- **Pros:** Cursor-first remains functional, protocol layer built on top, no forced migration
- **Cons:** Complexity, two parallel implementations
- **Recommendation:** **This roadmap assumes hybrid approach** (Track A + Track B)

**Decision Required:** Clarify repository positioning:
- Is this a **"Cursor workflow with governance"** (Track A only)?
- Or a **"protocol reference implementation"** (Track A + Track B)?

### Trade-Off 2: Manual Orchestration vs Automated State Machine

**Current State:** User manually runs commands (`@aidd.start`, `@aidd.plan`)  
**Protocol Vision:** Orchestration layer sequences phases and enforces gates

**Options:**

**A. Keep Manual Orchestration**
- **Pros:** Simple, no new dependencies, user retains control
- **Cons:** Violates protocol § Orchestration role, error-prone (user forgets steps)

**B. Build Automated Orchestrator**
- **Pros:** Protocol-compliant, reduces user errors, enforces gates
- **Cons:** Effort (Phase 4), requires state management

**Recommendation:** Phase 1 adds manual orchestration script (`aidd-orchestrate.sh`), Phase 4 builds full state machine. User can choose manual or automated.

### Trade-Off 3: Evidence Validation (Enforcement vs Recommendation)

**Current State:** Evidence-first is recommended but not enforced  
**Protocol Vision:** "No context invention" is a fundamental invariant

**Options:**

**A. Keep Evidence as Recommendation**
- **Pros:** Flexible, doesn't block workflow
- **Cons:** Users can generate artifacts without citations, violates invariant

**B. Enforce Evidence with Validation**
- **Pros:** Protocol-compliant, prevents hallucination
- **Cons:** Effort (Phase 1.3), may frustrate users initially

**Recommendation:** Phase 1.3 adds evidence validation as **optional flag** (`--evidence`). Later, make it default (with escape hatch `--skip-evidence` for rapid prototyping).

### Trade-Off 4: GitHub MCP Dependency

**Current State:** GitHub signals fetched via MCP (Cursor-specific)  
**Protocol Vision:** Tool-agnostic signal collection

**Options:**

**A. Keep MCP-First**
- **Pros:** Best UX in Cursor, structured data
- **Cons:** Locks to MCP, cannot use in other tools

**B. Replace with REST API**
- **Pros:** Tool-agnostic, no MCP dependency
- **Cons:** Requires GITHUB_TOKEN, more manual setup

**Recommendation:** Current fallback chain (MCP → gh CLI → REST) is acceptable. Phase 3.2 wraps this in tool-agnostic script (`scripts/fetch-github-signals.sh`).

---

## Final Observations

### What Should Be Celebrated

1. **Strong Governance Foundation**: Artifacts, gates, human review are well-designed.
2. **Validation Scripts**: `validate-plan.sh` and `review-check.sh` are excellent patterns.
3. **Evidence-First Principle**: Conceptually sound, just needs enforcement.
4. **Honest Tool Coupling**: README explicitly states "Cursor-first," no false claims of tool-agnosticism.

### What Requires Clarification

1. **Repository Identity**: Is this "AIDD protocol" or "Cursor workflow inspired by AIDD"?
   - **Recommendation:** Rename to `cursor-aidd-workflow` if Track A only, keep `aidd-flow` if Track A + Track B.

2. **Ideation Boundary**: Protocol is clear (Pre-AIDD space is ungoverned), repository is silent.
   - **Recommendation:** Phase 1.1 adds CONCEPT.md to encode this boundary.

3. **Role Separation**: Protocol defines 4 roles, repository has 1 (Cursor).
   - **Recommendation:** Phase 2 documents roles, Phase 4 implements delegation.

### What Must Not Be Lost

When evolving toward protocol compliance:

1. **Do not sacrifice usability for purity**: Cursor-first workflow is **functional**. Protocol convergence must preserve this.
2. **Do not break existing users**: Migration path must be incremental (symlinks, backwards compatibility).
3. **Do not invent where protocol is silent**: If protocol doesn't specify orchestration tool, document choice and trade-offs (LangGraph vs scripts).

### What Comes Next

**Immediate Next Steps (Week 1):**

1. **Decision:** Clarify repository positioning (Cursor-first vs protocol-first vs hybrid)
2. **Action:** Create CONCEPT.md template (Phase 1.1)
3. **Action:** Add approval status fields to artifact templates (Phase 1.2)
4. **Action:** Document role boundaries (Phase 2.1)

**If Protocol Convergence is Goal:**

Follow roadmap Phases 1-5 sequentially. Prioritize Phase 1 (governance) and Phase 3 (tool-agnostic artifacts) for maximum impact.

**If Cursor-First is Goal:**

Focus on Phase 1 only (strengthen governance within Cursor). Document decision to preserve tool coupling as "implementation choice."

---

## Conclusion

The `aidd-flow-sandbox` repository represents a **functional, governance-aware Cursor workflow** that demonstrates strong understanding of AIDD principles but exhibits **architectural drift** from the protocol's tool-agnostic vision.

This is **not a failure**—it is an **honest implementation choice**. The protocol document (added post-implementation) defines a more ambitious vision that the repository has not yet encoded.

**Path Forward:**

If the goal is **protocol convergence**, follow the roadmap above (Phases 1-5, 63-96 days effort).  
If the goal is **Cursor-first workflow**, strengthen governance (Phase 1 only, 9-14 days), document tool coupling as intentional.

Either path is valid. The critical step is **deciding which path to take** and **documenting that decision** in the repository.

---

**End of Analysis Report**
