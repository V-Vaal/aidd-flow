# Governance Layer

Rules that enforce evidence, auditability, and safe escalation.

## Artefact Statuses

Artefacts (INTAKE.md, PLAN.md, REVIEW.md) have explicit statuses:
- **DRAFT**: Initial creation, incomplete or unverified
- **REVIEWED**: Content verified against evidence, ready for approval
- **APPROVED**: Final status, validated and ready for implementation or merge

**Critical rule**: File existence does not imply approval. Status must be explicitly stated in the artefact.

## Do-Not-Invent Policy

**Never guess or assume unproven facts:**
- Endpoints, routes, API versions → verify in codebase or docs
- Regex patterns, validation rules → cite source files
- Migration conventions, versioning schemes → reference existing examples
- Framework defaults, library behaviors → check documentation or tests

**If uncertain:**
- Document assumption in "Open Questions" section
- Mark as DRAFT until evidence is provided
- Block implementation until assumption is proven

## Evidence-First Principle

All claims in INTAKE, PLAN, and REVIEW must cite evidence:

**INTAKE:**
- Constraints: cite file paths showing limitations
- Risks: reference specific code locations or patterns
- Acceptance criteria: link to requirements or test files

**PLAN:**
- File selections: justify with codebase structure or dependencies
- Implementation steps: reference existing patterns or conventions
- Test strategy: cite existing test files or frameworks

**REVIEW:**
- Verdict rationale: reference specific code changes and test results
- Test evidence: include command outputs or CI check results
- Risk assessment: cite file paths and line numbers

**Evidence format:**
- File paths: `path/to/file.ext:line-range`
- Commands: `command --flags` with expected output
- Code references: specific functions, classes, or patterns

## Skeptic Pass

Second review pass that flags claims without evidence:

**Checklist:**
- [ ] Every technical claim has a file path or command citation
- [ ] Assumptions are explicitly marked in "Open Questions"
- [ ] Implementation steps reference existing code patterns
- [ ] Test strategy cites existing test infrastructure
- [ ] Risk statements point to specific code locations

**If evidence missing:**
- Mark artefact as DRAFT
- Request evidence or move claim to "Open Questions"
- Block approval until evidence is provided

## Risk Escalation Protocol

**When scope or risk increases during implementation:**
1. **STOP** implementation immediately
2. **UPDATE** INTAKE.md with new scope/risks
3. **REASSESS** PLAN.md if approach needs changes
4. **RE-APPROVE** INTAKE and PLAN before continuing

**Triggers for escalation:**
- New dependencies discovered
- Additional files need modification beyond PLAN
- Security concerns identified
- Performance implications found
- Breaking changes to existing APIs

**Escalation gates:**
- Updated INTAKE must be REVIEWED and APPROVED
- PLAN must be updated and re-validated
- Review must acknowledge escalated risks

## Minimal Reproducible Proof

Every change must include proof that it works:

**Implementation proof:**
- Commands that demonstrate the change: `bash script.sh` with output
- CI checks that validate correctness: test results or lint passes
- Manual verification steps: specific actions and expected outcomes

**Review proof:**
- Test execution: command and output showing pass/fail
- Validation scripts: `validate-plan.sh` or `aidd-check.sh` results
- Manual checks: UI screenshots, API responses, log outputs

**Proof format:**
- Inline in artefact: command blocks with outputs
- References: links to CI runs, test reports, or verification logs
- Screenshots: for UI changes or visual verification
