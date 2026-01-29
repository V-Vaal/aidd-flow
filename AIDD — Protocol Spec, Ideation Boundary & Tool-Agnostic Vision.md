# AIDD — Protocol Spec, Ideation Boundary & Tool-Agnostic Vision

## Purpose of this document

This document defines the **target vision** of AIDD (AI-Driven Development) as a
**tool-agnostic, human-governed development protocol**.

It intentionally describes:
- what AIDD **is**,
- what AIDD **is not**,
- and **where AIDD begins**.

It does **not** describe the current state of the `aidd-flow` repository.

This document is meant to serve as:
1. a **normative reference**,
2. a **baseline for repository audits**,
3. a **roadmap anchor** between vision and implementation.

---

## Core Positioning

AIDD is **not**:
- an ideation framework,
- an automation system,
- an autonomous agent architecture,
- a tool-specific workflow.

AIDD **is**:
- a governance protocol for AI-assisted engineering,
- a guardrail against context invention,
- a reasoning system with explicit phases and gates,
- a method where **humans retain decision authority**.

AIDD governs **engineering reality**, not creative intuition.

---

## Pre-AIDD: Concept & Ideation Space

### Conceptual Boundary (Critical)

AIDD does **not** govern ideation.

Before AIDD begins, there exists a **free conceptual space** where:
- ideas are vague,
- hypotheses are fragile,
- contradictions are acceptable,
- coherence is not required.

This space is intentionally unconstrained.

### Purpose of the Concept Phase

The concept / ideation phase exists to:
- explore intuitions,
- test mental models,
- discuss analogies,
- ask “what if?” questions,
- discard ideas without cost.

This phase must remain:
- non-binding,
- non-audited,
- non-governed.

---

## Transition Point: When an Idea Enters AIDD

An idea enters AIDD **only when an explicit decision is made**:

> “This idea deserves to be confronted with reality.”

This moment is a **governance boundary**.

From that point:
- the idea may be challenged,
- the idea may be invalidated,
- the idea may be rejected.

This is considered a **successful outcome**, not a failure.

---

## Phase -1 — Concept Freeze (Optional but Explicit)

Artifact: `CONCEPT.md` (or `IDEA.md`)

Purpose:
- freeze the idea *just enough* to make it analyzable,
- without formalizing it prematurely.

Recommended content:
- initial intuition
- perceived problem
- explicit assumptions
- known unknowns
- what is deliberately *not* decided
- why this concept is worth auditing

Restrictions:
- no solution design
- no implementation plan
- no technical commitments

Once this artifact exists, AIDD may start.

---

## Fundamental Invariants (Non-Negotiable)

These rules apply **once AIDD has started**.

### 1. No context invention
- Facts must be observable or explicitly marked as unknown.
- Absence of data must be documented, never inferred.

### 2. Strict separation of phases
Audit ≠ Intake ≠ Plan ≠ Execution ≠ Review

No implicit transitions.

### 3. Human decision authority
- AI may suggest, detect, or flag.
- AI must never decide, approve, or conclude.

### 4. Explicit gates
Each phase transition requires:
- a concrete artifact,
- explicit validation,
- acknowledgment of risks or unknowns.

### 5. Minimal scope & minimal diffs
- Scope expansion is a failure mode.
- Precision is preferred over ambition.

---

## Canonical AIDD Phases & Artifacts

### Phase 0 — Entry Point (`aidd.start`)

Defines **why** an AIDD cycle exists.

Modes:
- **Targeted audit** (Issue / PR / specific objective)
- **Exploratory audit** (repository or concept analysis)

Output:
- deterministic target definition
- explicit documentation of missing signals

---

### Phase 1 — Audit

Artifact: `AUDIT.md`

Contains:
- factual observations
- explicit unknowns
- risks and ambiguities
- contradictions

Contains **no prescriptions**.

Optional support artifact:
- `AUDIT.seed.md` (machine-generated factual scan)

---

### Phase 2 — Intake (Targeted mode only)

Artifact: `INTAKE.md`

Defines:
- validated scope
- success criteria
- escalation triggers
- explicit exclusions

Execution must be blocked if Intake is incomplete.

---

### Phase 3 — Plan

Artifact: `PLAN.md`

Defines:
- approved actions
- constraints
- success conditions

No execution without an approved plan.

---

### Phase 4 — Execution

Artifacts:
- code diffs
- test outputs
- execution notes

Rules:
- no scope expansion
- no autonomous arbitration
- sensitive points must be flagged, not resolved

---

### Phase 5 — Review

Artifact: `REVIEW.md`

Mandatory sections:
- evidence & proofs
- test results
- diffs summary
- **Sensitive points requiring human decision**
  - or explicit statement: “None detected.”

---

## Cognitive Role Model (Tool-Independent)

AIDD defines **roles**, not tools.

### A. Reasoning — “The Brain”
Purpose:
- abstraction
- synthesis
- architectural reasoning
- contradiction detection

Typical tools:
- Claude (UI or IDE-integrated)
- ChatGPT
- other high-capability reasoning models

Restrictions:
- no execution authority
- no approval power

---

### B. Execution — “The Arms”
Purpose:
- apply validated plans
- produce diffs
- write tests
- update artifacts

Typical tools:
- Cursor
- Claude Code

Restrictions:
- no scope decisions
- no design arbitration

---

### C. Orchestration — “The Conductor”
Purpose:
- sequence phases
- enforce gates
- route artifacts
- manage controlled loops

Typical tools:
- LangGraph
- scripts
- task runners

Restrictions:
- no conclusions
- no autonomous validation

---

### D. Workers & Utilities — “The Hands”
Purpose:
- raw scans
- extraction
- pattern detection
- summarization

Typical tools:
- local models (Ollama: DeepSeek, Qwen, Codestral…)
- linters, static analyzers, grep-like tools

Restrictions:
- no synthesis
- no judgment
- no decision authority

---

## Tool-Agnostic Integration Rule

Any tool integrated into AIDD must:
1. operate in a **clearly identified role**
2. produce or consume **explicit artifacts**
3. respect **human validation gates**
4. be **replaceable without breaking the protocol**

Violation of these rules makes the tool optional or incompatible.

---

## Swarms, Skills, Cowork, Agentic Systems

These mechanisms are treated as:
- **execution strategies**, not authorities.

They may:
- parallelize tasks
- specialize subtasks
- aggregate outputs

They must never:
- choose scope
- validate outcomes
- approve changes

All swarm-like execution must converge into:
- a single REVIEW artifact
- with explicit human validation.

---

## Repository Scanning & Analysis Strategy

Repository-wide scanning and analysis require:
- global semantic understanding
- architectural reasoning
- contradiction detection

Therefore:
- **high-capability reasoning models (e.g. Claude)** are preferred for
  repo scans and architectural audits.
- local models are limited to **factual pre-seeding** tasks.

This is a design choice, not an implementation constraint.

---

## Expected Outcome of an AIDD Repository Scan

When scanning the `aidd-flow` repository against this document, the analysis must:
1. identify alignment with the protocol
2. detect gaps, drift, or ambiguity
3. classify issues (conceptual / structural / tooling)
4. propose a **progressive roadmap**, not a rewrite

The objective is convergence, not reinvention.

---

## Final Principle

AIDD must remain:
- simple to operate
- hard to misuse
- resilient to tool churn
- explicitly human-governed

AIDD begins **when an idea is accepted as challengeable**.
Anything before that remains free.
