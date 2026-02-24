# Plan Prompt

## Purpose

Create a detailed technical plan with architecture, implementation steps, files to modify, tests, and rollback strategy. This is the second step in the AIDD workflow (Editor role), following INTAKE approval.

## Inputs Required

- INTAKE.md (requirements, constraints, acceptance criteria)
- AUDIT.md (current system state, if available)
- `aidd/memory/techContext.md` (technical stack and context)
- `aidd/memory/systemPatterns.md` (architectural patterns, if available)
- Repository codebase for understanding current implementation

## Output Artefact

- Creates or updates: `aidd/work/PLAN.md`

## Procedure

1. **Review INTAKE.md**
   - Read goal and scope
   - Note constraints and assumptions
   - Review acceptance criteria and Definition of Done
   - Understand risks and mitigation strategies

2. **Review system context**
   - Read AUDIT.md if available for architecture overview
   - Read `aidd/memory/techContext.md` for technical stack
   - Read `aidd/memory/systemPatterns.md` for design patterns
   - Review relevant source code files to understand current implementation

3. **Define the goal**
   - Restate the goal clearly (aligned with INTAKE.md)
   - Ensure technical goal matches business goal

4. **Define scope**
   - List what is in scope (reference INTAKE.md)
   - List what is explicitly out of scope (reference INTAKE.md)
   - Add any technical scope clarifications

5. **Identify files to touch**
   - List all files that will be **created** (with paths)
   - List all files that will be **modified** (with paths)
   - For each file, note what will change:
     - New functions/classes
     - Modified functions/classes
     - Configuration changes
     - Test additions/modifications
   - Consider impact on related files (imports, dependencies)

6. **Break down into steps**
   - Create numbered, sequential steps
   - Each step should be:
     - Clear and actionable
     - Atomic (one logical unit of work)
     - Testable (can verify completion)
   - Consider dependencies between steps
   - Include setup and preparation steps
   - Include cleanup steps if needed

7. **Define tests and checks**
   - Unit tests to write or update (list test files)
   - Integration tests required (list test scenarios)
   - Manual testing steps (list scenarios)
   - **Mandatory**: Include `bash scripts/aidd-check.sh`
   - **If UI changes**: Include `bash scripts/aidd-verify-ui.sh`
   - Performance tests if applicable
   - Security tests if applicable

8. **Plan rollback strategy**
   - How to revert changes if something goes wrong
   - Git revert strategy (commit hashes, branches)
   - Database migration rollback (if applicable)
   - Configuration rollback steps
   - Data restoration steps (if applicable)
   - Communication plan if rollback affects users

9. **Document security considerations** (generic)
   - Input validation requirements
   - Authentication/authorization checks
   - Data privacy considerations
   - Secure communication requirements
   - Dependency security (check for vulnerabilities)

10. **Document notes**
    - Implementation risks and edge cases
    - Important considerations or gotchas
    - Dependencies on other work or systems
    - Performance considerations
    - Future improvements to consider

11. **Create PLAN.md**
    - Use the template structure:
      - `# Technical Plan`
      - `## How to use` (brief instruction)
      - `## Goal`
      - `## Scope` (with In Scope and Out-of-scope subsections)
      - `## Files to touch`
      - `## Steps` (numbered list)
      - `## Tests / Checks` (checklist format)
      - `## Rollback plan`
      - `## Notes`
    - Fill each section with content from steps 1-10
    - Save to `aidd/work/PLAN.md`

12. **Plan checklist** (for validation)
    - Verify PLAN.md contains all required sections:
      - ✓ Goal
      - ✓ Scope (with Out-of-scope)
      - ✓ Files to touch
      - ✓ Steps
      - ✓ Tests / Checks (or "Tests")
      - ✓ Rollback (or "Rollback plan")
    - Run `bash scripts/validate-plan.sh` to validate structure

## Implementation Guidance

**During implementation, maintain sensitive points tracking:**

- Create or update `aidd/work/SENSITIVE_NOTES.md` (facts-only) when encountering:
  - Ambiguous requirements or specifications
  - Design decisions requiring human judgment
  - Trade-offs between implementation approaches
  - Security considerations needing expert review
  - Performance implications requiring validation
  - Breaking changes or compatibility concerns
  - Failing tests that reveal unclear requirements
  - Conflicting constraints from INTAKE.md or PLAN.md

- **Format for SENSITIVE_NOTES.md:**
  ```markdown
  # Sensitive Points (Facts Only)
  
  ## Point 1: [Brief description]
  - **Location**: `file/path.ts:45-60` (or diff reference)
  - **Context**: [Factual description of the situation]
  - **Evidence**: [Failing test output, ambiguous requirement citation, etc.]
  - **Requires decision on**: [What needs human judgment]
  
  ## Point 2: [Brief description]
  ...
  ```

- **Rules:**
  - **Do NOT make decisions**: Only record flags for human review
  - **Facts only**: No prescriptions, no "should" language
  - **Include evidence**: File paths, line numbers, test outputs, requirement citations
  - **Update during implementation**: Add points as they are encountered
  - This file will be referenced during review (see prompts/review.md step 3)

## Gate Reminders

- **CRITICAL**: Before implementation, run `bash scripts/validate-plan.sh` to ensure PLAN.md is valid
- **DO NOT PROCEED** with implementation if PLAN.md validation fails
- After successful modifications, update `aidd/memory/activeContext.md`
- Review is mandatory: create REVIEW.md with Verdict (APPROVE | CHANGES_REQUESTED)
- No task is DONE without review approval (Verdict: APPROVE)

## Definition of Done

- PLAN.md exists at `aidd/work/PLAN.md`
- All required sections are present (validated by validate-plan.sh)
- Steps are clear, sequential, and actionable
- Files to touch are listed with paths
- Tests/Checks include mandatory aidd-check.sh (and aidd-verify-ui.sh if UI changes)
- Rollback plan is documented
- PLAN.md validation passes: `bash scripts/validate-plan.sh` returns exit code 0
