# Technical Plan Template

Use this template to document the technical approach before implementation.

## Architecture

**High-level design:**
- [ ] System architecture diagram (text or mermaid)
- [ ] Component boundaries defined
- [ ] Data flow documented
- [ ] Integration points identified
- [ ] Technology choices justified

## Data Flow

**How does data move through the system?**
- [ ] Input sources identified
- [ ] Processing steps documented
- [ ] Output destinations defined
- [ ] Data transformations described
- [ ] Error paths documented
- [ ] State management approach

## Threats

**Security and reliability threats:**
- [ ] Threat model considered
- [ ] Attack vectors identified
- [ ] Mitigation strategies defined
- [ ] Input validation points
- [ ] Authentication/authorization checks
- [ ] Error handling strategy
- [ ] Fail-safe mechanisms

## Edge Cases

**What could go wrong?**
- [ ] Zero/null/empty inputs
- [ ] Maximum values (overflow, limits)
- [ ] Concurrent operations
- [ ] Network failures
- [ ] Partial failures
- [ ] State inconsistencies
- [ ] Race conditions
- [ ] Timeout scenarios

## Test Matrix

**What will we test?**
- [ ] Unit tests: functions, classes, modules
- [ ] Integration tests: component interactions
- [ ] E2E tests: user flows (if UI)
- [ ] Security tests: input validation, auth, injection
- [ ] Performance tests: load, stress, latency
- [ ] Regression tests: existing functionality
- [ ] Edge case tests: identified scenarios

## Instrumentation and Logging

**How will we observe the system?**
- [ ] Logging points identified
- [ ] Log levels defined (debug, info, warn, error)
- [ ] Structured logging format
- [ ] Metrics to track
- [ ] Alerts configured
- [ ] Debugging hooks added
- [ ] Performance profiling points

## Migration

**If changing existing systems:**
- [ ] Migration strategy defined
- [ ] Data migration plan
- [ ] Backward compatibility considered
- [ ] Rollback plan
- [ ] Feature flags (if applicable)
- [ ] Gradual rollout plan
- [ ] Communication plan

## Implementation Steps

**Breakdown of work:**
1. [ ] Step 1: Description
2. [ ] Step 2: Description
3. [ ] Step 3: Description
4. [ ] Step N: Description

## Dependencies

**What do we need?**
- [ ] External libraries/packages
- [ ] Internal services/APIs
- [ ] Infrastructure components
- [ ] Data sources
- [ ] Team dependencies

## Timeline

**Estimated effort:**
- [ ] Step 1: X hours/days
- [ ] Step 2: X hours/days
- [ ] Step 3: X hours/days
- [ ] Total: X hours/days
- [ ] Buffer for unknowns: X%

## Risks and Mitigations

**Technical risks:**
- [ ] Risk 1: Mitigation strategy
- [ ] Risk 2: Mitigation strategy
- [ ] Risk 3: Mitigation strategy

## Review Checklist

Before starting implementation:
- [ ] Architecture reviewed
- [ ] Security threats addressed
- [ ] Edge cases identified
- [ ] Test plan complete
- [ ] Logging strategy defined
- [ ] Migration plan (if applicable) reviewed
- [ ] Team alignment achieved

## Active Capabilities

**Query-driven GitHub signals:**
- Config-based queries define what external signals to fetch
- Human-defined query parameters (repository, filters, labels)
- Facts-only output (IDs, titles, labels, state, updated_at)
- No automatic interpretation or prioritization

**Audit Seed Agent:**
- Automated repository analysis and risk detection
- Pattern recognition for common issues
- Evidence collection for governance compliance
- Analysis only, non-binding recommendations

**Explicit separation:**
- **Audit** ≠ **Decision** ≠ **Intake**
- Audit provides facts and analysis
- Decision remains human responsibility
- Intake captures requirements and constraints
- No automatic decision-making from audit outputs
