# Review Prompt

## Purpose

Perform code review with test evidence, risk assessment, and formal verdict. This is the review phase in the AIDD workflow (Reviewer role), required before marking work as complete.

## Inputs Required

- Implemented changes (code diff, modified files)
- PLAN.md that was implemented
- Test results and evidence
- `.cursor/memory/techContext.md` (for domain-specific checklist suggestions)
- `.cursor/review/review-checklist-web3.md` (if Domain is web3)
- `.cursor/review/review-checklist-ml.md` (if Domain is ml)

## Output Artefact

- Creates or updates: `.cursor/work/REVIEW.md`
- Runs validation: `bash .cursor/scripts/review-check.sh`

## Procedure

1. **Summarize changes**
   - Document what was changed, added, or removed
   - Reference the PLAN.md that was implemented
   - Note any deviations from the plan (and whether they were justified)
   - List files modified and created

2. **Assess risks**
   - Review security risks:
     - Input validation
     - Authentication/authorization
     - Data exposure
     - Dependency vulnerabilities
   - Review performance risks:
     - Scalability concerns
     - Resource usage
     - Response time impact
   - Review integration risks:
     - Breaking changes
     - Compatibility issues
     - Dependency conflicts
   - Document mitigation strategies for each identified risk

3. **Document sensitive points requiring human decision**
   - Check if `.cursor/work/SENSITIVE_NOTES.md` exists (created during implementation)
   - If exists:
     - Read and incorporate its content
     - List all sensitive points from SENSITIVE_NOTES.md plus any detected during review:
       - Ambiguous requirements or specifications
       - Design decisions that require human judgment
       - Trade-offs between approaches
       - Security considerations requiring expert review
       - Performance implications needing validation
       - Breaking changes or compatibility concerns
     - For each point, include:
       - Description (purely factual, no prescriptions)
       - Evidence pointers: file paths, line numbers, diff references
       - Context: failing tests, ambiguous requirements, conflicting constraints
   - If SENSITIVE_NOTES.md does NOT exist:
     - Write "None detected." (explicit statement)
     - Do NOT invent or assume sensitive points
   - **Do NOT make decisions**: Only document flags for human review

4. **Document test evidence**
   - List all tests that were run:
     - Unit tests (files, results)
     - Integration tests (scenarios, results)
     - Manual tests (steps, results)
   - **Mandatory**: Include `bash .cursor/scripts/aidd-check.sh` results
   - **If UI changes**: Include `bash .cursor/scripts/aidd-verify-ui.sh` results
   - Document test coverage if available
   - Note any tests that failed and were fixed
   - Note any tests that are missing or should be added

5. **Reference security checklists** (domain-specific)
   - Read `.cursor/memory/techContext.md` to determine Domain
   - If Domain is "web3":
     - Reference `.cursor/review/review-checklist-web3.md`
     - Verify access control, reentrancy, external calls, events, input validation, DOS/gas risks, oracle/price dependency, upgradeability, invariant/property-based tests
   - If Domain is "ml":
     - Reference `.cursor/review/review-checklist-ml.md`
     - Verify data leakage, train/val/test split, reproducibility, dataset provenance, metrics definition, overfitting checks, configuration tracking, baseline comparison
   - If Domain is "mixed":
     - Reference both checklists
   - Document which checklist items were verified
   - Note any checklist items that need attention

6. **Set verdict**
   - **MANDATORY**: Include Verdict field in format: `**Verdict**: APPROVE` or `**Verdict**: CHANGES_REQUESTED`
   - Verdict must be exactly one of:
     - `APPROVE` - Changes are approved and ready for merge/deployment
     - `CHANGES_REQUESTED` - Changes are needed before approval
   - If CHANGES_REQUESTED:
     - List required changes clearly
     - Prioritize changes (critical vs nice-to-have)
     - Provide actionable feedback

7. **Document follow-ups**
   - Any follow-up tasks or items (even if approved)
   - Future improvements to consider
   - Technical debt created or addressed
   - Documentation updates needed
   - Monitoring or observability additions

8. **Create REVIEW.md**
   - Use the template structure:
     - `# Code Review`
     - `## Summary of changes`
     - `## Risk assessment`
     - `## Sensitive points requiring human decision` - **MANDATORY**
     - `## Test evidence`
     - `## Security checklist references` (Web3 / ML if applicable)
     - `## Verdict` (APPROVE | CHANGES_REQUESTED) - **MANDATORY**
     - `## Follow-ups`
   - Fill each section with content from steps 1-7
   - Save to `.cursor/work/REVIEW.md`

9. **Run review validation**
   - Execute: `bash .cursor/scripts/review-check.sh`
   - Verify Verdict field is present and valid
   - Address any warnings about test evidence
   - Fix any validation errors

## Gate Reminders

- Review is **MANDATORY** before marking work as done
- Verdict field is required and must be APPROVE or CHANGES_REQUESTED
- Work is **NOT DONE** until Verdict is APPROVE
- After review approval, update `.cursor/memory/activeContext.md` with completion details
- Do not proceed to PR/merge if Verdict is CHANGES_REQUESTED

## Definition of Done

- REVIEW.md exists at `.cursor/work/REVIEW.md`
- Verdict field is present and set to APPROVE or CHANGES_REQUESTED
- Test evidence section includes mandatory aidd-check.sh results (and aidd-verify-ui.sh if UI changes)
- Risk assessment is documented
- Review validation passes: `bash .cursor/scripts/review-check.sh` returns exit code 0
- If Verdict is APPROVE: work is ready for merge/deployment
- If Verdict is CHANGES_REQUESTED: required changes are clearly documented

