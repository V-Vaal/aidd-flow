# PR Message Prompt

## Purpose

Generate a conventional commit message and comprehensive PR description based on AIDD workflow artifacts (INTAKE, PLAN, REVIEW, activeContext). This ensures consistent, well-documented PR messages that reference the AIDD workflow.

## Inputs Required

- INTAKE.md (goal and scope)
- PLAN.md (implementation details and steps)
- REVIEW.md (review findings and verdict - must be APPROVE)
- `.cursor/memory/activeContext.md` (current state and recent changes)
- Git changes (git diff, modified files)
- Implemented code changes

## Output Artefact

- Creates or updates: `.cursor/work/PR.md`

## Procedure

1. **Verify prerequisites**
   - Ensure REVIEW.md exists and Verdict is APPROVE
   - If Verdict is CHANGES_REQUESTED, do not proceed (fixes must be made first)
   - Ensure all workflow gates have passed:
     - PLAN.md validated
     - Tests pass (aidd-check.sh)
     - Review approved

2. **Review INTAKE.md**
   - Extract goal and scope
   - Note acceptance criteria
   - Understand the problem being solved
   - Capture user story if present

3. **Review PLAN.md**
   - Extract implementation approach
   - Note files that were changed
   - Understand the solution design
   - Note any deviations from plan

4. **Review REVIEW.md**
   - Extract verdict (must be APPROVE)
   - Note test evidence and results
   - Understand risk assessment
   - Note any follow-up items

5. **Review activeContext.md**
   - Extract recent changes
   - Note current system state
   - Understand context and dependencies

6. **Review git changes**
   - Examine files changed (git diff --stat)
   - Understand scope of changes
   - Note significant modifications
   - Identify breaking changes if any

7. **Generate conventional commit message**
   - Format: `<type>(<scope>): <subject>`
   - Types:
     - `feat`: New feature
     - `fix`: Bug fix
     - `refactor`: Code refactoring
     - `docs`: Documentation changes
     - `test`: Test additions or changes
     - `chore`: Maintenance tasks
   - Scope: optional, component or area affected
   - Subject: brief description (50 chars or less, imperative mood)
   - Body (optional): detailed explanation, reference INTAKE goal
   - Example: `feat(auth): add OAuth2 login support`
   - Example: `fix(api): resolve rate limiting issue`

8. **Generate PR title**
   - Clear, concise summary (one line)
   - Should match commit message subject or be more descriptive
   - Include type prefix if team convention (e.g., `[FEAT]`, `[FIX]`)

9. **Generate PR description**
   - **Context/Problem**: What problem does this solve? (from INTAKE.md)
   - **Goal**: What are we trying to achieve? (from INTAKE.md)
   - **Changes**: What changed? (from PLAN.md and git diff)
     - List files modified/created
     - Summarize implementation approach
   - **Why**: Why this approach? (from PLAN.md notes)
   - **Testing**: How was this tested? (from REVIEW.md test evidence)
     - Unit tests
     - Integration tests
     - Manual tests
     - aidd-check.sh results
     - aidd-verify-ui.sh results (if applicable)
   - **Risks**: What are the risks? (from REVIEW.md risk assessment)
   - **Rollout/Rollback**: How to deploy/rollback? (from PLAN.md rollback plan)
   - **Checklist**:
     - [ ] PLAN.md validated
     - [ ] Tests pass (aidd-check.sh)
     - [ ] UI verified (if applicable)
     - [ ] REVIEW.md Verdict: APPROVE
     - [ ] activeContext.md updated
   - **Links**:
     - Link to INTAKE.md
     - Link to PLAN.md
     - Link to REVIEW.md
   - **Follow-ups**: Any follow-up tasks? (from REVIEW.md)

10. **Create PR.md**
    - Use the template structure:
      - `# PR Message`
      - `## Commit Message` (conventional format)
      - `## PR Title`
      - `## PR Description` (with all sections from step 9)
    - Fill each section with content from steps 2-9
    - Save to `.cursor/work/PR.md`

11. **Format for use**
    - Provide commit message as ready-to-use text (can copy-paste)
    - Provide PR description in markdown format (can copy-paste)
    - Ensure all links use correct paths (`.cursor/work/INTAKE.md`, etc.)

## Gate Reminders

- PR should only be created if REVIEW.md Verdict is APPROVE
- Ensure all workflow gates have passed before generating PR message
- After PR is merged, update `.cursor/memory/activeContext.md` with merge details
- Follow `.cursor/rules/05-workflows-and-processes/5-open-source-pr.mdc` for PR format if present

## Definition of Done

- PR.md exists at `.cursor/work/PR.md`
- Commit message follows conventional format
- PR title is clear and descriptive
- PR description includes all required sections (Context, Goal, Changes, Why, Testing, Risks, Rollout/Rollback)
- Checklist is complete
- Links to INTAKE.md, PLAN.md, and REVIEW.md are present
- All content is based on actual AIDD workflow artifacts

