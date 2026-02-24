# Intake Prompt

## Purpose

Capture requirements, constraints, assumptions, risks, and acceptance criteria for a new feature or task. This is the first step in the AIDD workflow (Architect role).

## Inputs Required

- Feature request or task description from user
- Business requirements and context
- Technical constraints and limitations
- Existing AUDIT.md (if available) for repository context
- `aidd/memory/techContext.md` for technical stack information

## Output Artefact

- Creates or updates: `aidd/work/INTAKE.md`

## Procedure

1. **Understand the problem statement**
   - Read the user's feature request or task description
   - Clarify ambiguous requirements by asking questions if needed
   - Document the core problem being solved

2. **Define the goal**
   - Write a clear, concise goal statement
   - Ensure it aligns with the problem statement
   - Make it measurable if possible

3. **Define scope**
   - List what is **in scope** (In Scope section)
   - List what is **explicitly out of scope** (Out-of-scope section)
   - Be specific to prevent scope creep
   - Reference related features or systems if relevant

4. **Capture user story** (if applicable)
   - Format: "As a [user type], I want [goal] so that [benefit]"
   - Include acceptance criteria from user perspective

5. **Document constraints**
   - Technical constraints (languages, frameworks, platforms)
   - Time constraints (deadlines, milestones)
   - Resource constraints (team size, budget)
   - Compliance or regulatory constraints
   - Integration constraints (existing systems, APIs)

6. **Document assumptions**
   - Assumptions about current system state
   - Assumptions about user behavior or needs
   - Assumptions about dependencies or external systems
   - Assumptions about data or infrastructure

7. **Define acceptance criteria**
   - Create a "Definition of Done" checklist
   - Include functional requirements (what the feature must do)
   - Include non-functional requirements (performance, security, usability)
   - Include test requirements (unit tests, integration tests, manual tests)
   - Make criteria testable and specific

8. **Assess risks**
   - Technical risks (complexity, unknowns, dependencies)
   - Implementation risks (time, resources, skills)
   - Integration risks (breaking changes, compatibility)
   - Business risks (user impact, data loss, security)
   - For each risk, document:
     - Risk description
     - Likelihood and impact
     - Mitigation strategy

9. **Create INTAKE.md**
   - Use the template structure:
     - `# Intake`
     - `## How to use` (brief instruction)
     - `## Goal`
     - `## Scope` (with In Scope and Out-of-scope subsections)
     - `## Constraints`
     - `## Assumptions`
     - `## Definition of Done`
     - `## Risks`
   - Fill each section with content from steps 1-8
   - Save to `aidd/work/INTAKE.md`

## Gate Reminders

- After INTAKE is complete, proceed to PLAN creation
- The PLAN must be validated with `bash scripts/validate-plan.sh` before implementation
- After successful modifications, update `aidd/memory/activeContext.md`
- Review is mandatory: create REVIEW.md with Verdict (APPROVE | CHANGES_REQUESTED)

## Definition of Done

- INTAKE.md exists at `aidd/work/INTAKE.md`
- All required sections are present and filled
- Goal is clear and measurable
- Scope explicitly defines in-scope and out-of-scope items
- Definition of Done checklist is complete and testable
- Risks are identified with mitigation strategies
