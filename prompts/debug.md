# Debug Prompt

## Purpose

Systematically debug issues by documenting reproduction steps, root cause analysis, candidate fixes, and verification. This prompt guides structured debugging and ensures fixes are properly tested.

## Inputs Required

- Bug report or issue description
- Error messages, logs, or stack traces
- Affected code files and components
- Test files related to the issue
- System state and environment information

## Output Artefact

- Creates or updates: `aidd/work/DEBUG.md`

## Procedure

1. **Document reproduction steps**
   - List exact steps to reproduce the issue
   - Include environment setup (OS, dependencies, versions)
   - Include input data or test cases
   - Note any preconditions required
   - Make steps clear and repeatable

2. **Document observed behavior**
   - Describe what actually happens (the bug)
   - Include error messages, logs, or stack traces
   - Note any side effects or unexpected behavior
   - Include screenshots or output if relevant

3. **Document expected behavior**
   - Describe what should happen (correct behavior)
   - Reference requirements or specifications if available
   - Note expected outputs or state changes

4. **Analyze root cause**
   - Review relevant code files
   - Trace execution flow
   - Identify the suspected root cause:
     - Logic error
     - Race condition
     - Resource leak
     - Configuration issue
     - Dependency issue
     - Data issue
   - Document why this is the suspected cause

5. **Propose candidate fix**
   - Describe the fix approach
   - List files that need to be modified
   - Explain how the fix addresses the root cause
   - Consider alternative approaches if applicable
   - Note any trade-offs or side effects of the fix

6. **Plan verification steps**
   - List tests to run to verify the fix:
     - Unit tests
     - Integration tests
     - Manual reproduction steps (should now pass)
     - Regression tests (ensure no new issues)
   - Include: `bash scripts/aidd-check.sh`
   - Include: `bash scripts/aidd-verify-ui.sh` (if UI-related)
   - Document expected test results

7. **Recommend test updates**
   - Identify if new tests should be written to prevent regression
   - Identify if existing tests should be updated
   - Note test gaps that allowed the bug to exist

8. **Create DEBUG.md**
   - Use the template structure:
     - `# Debug`
     - `## Reproduction steps`
     - `## Observed behavior`
     - `## Expected behavior`
     - `## Suspected root cause`
     - `## Candidate fix`
     - `## Verification steps`
     - `## Test recommendations`
   - Fill each section with content from steps 1-7
   - Save to `aidd/work/DEBUG.md`

9. **Implement fix** (if proceeding)
   - Apply the candidate fix
   - Run verification steps
   - Update tests as recommended
   - Document results in DEBUG.md

## Gate Reminders

- After fix is implemented, create or update PLAN.md if the fix is non-trivial
- Run `bash scripts/validate-plan.sh` if PLAN.md was created/updated
- After successful fix, update `aidd/memory/activeContext.md`
- Review is mandatory: create REVIEW.md with Verdict (APPROVE | CHANGES_REQUESTED)
- Ensure all verification steps pass before marking fix complete

## Definition of Done

- DEBUG.md exists at `aidd/work/DEBUG.md`
- Reproduction steps are clear and repeatable
- Root cause is identified and documented
- Fix is implemented and verified
- All verification steps pass (including aidd-check.sh)
- Tests are updated or added to prevent regression
- REVIEW.md exists with Verdict: APPROVE
- `aidd/memory/activeContext.md` is updated
