# 5 aidd loop

Workflow Loop:
- Follow Intake → Plan → Implement → Verify → PR sequence
- Never skip the Intake phase for new features
- Always create a technical plan before implementation
- Never mark work as done without verification
- Always verify in browser for UI changes
- Run aidd-check.sh before creating PR

Intake Phase:
- Use intake.md template for new features
- Document goal, constraints, and non-goals clearly
- Identify risks and acceptance criteria
- Define test plan and rollout strategy
- Get approval before proceeding to Plan

Plan Phase:
- Use technical-plan.md template
- Document architecture and data flow
- Identify threats and edge cases
- Define test matrix
- Plan instrumentation and logging
- Review plan before implementation

Implement Phase:
- Follow P0/P1/P2 rules (security-first)
- Use aidd-context.sh to provide LLM context
- Write code with appropriate rules applied
- Add tests as you implement
- Document as you go

Verify Phase:
- Run aidd-check.sh and fix all errors
- Execute test plan from intake
- Verify security invariants
- Check Definition of Done for your domain
- For UI: verify in actual browser
- For smart contracts: verify all invariants
- For ML: verify reproducibility

PR Phase:
- Use rules/05-workflows-and-processes/5-open-source-pr.md format
- Include security checklist
- Link to intake/plan documents
- Ensure all checks pass
- Request review from team

Verification Requirements:
- All tests must pass
- Linting and type checking must pass
- Security review completed
- Documentation updated
- No breaking changes (or migration plan)
- Browser verification for UI changes
- On-chain verification for smart contracts
