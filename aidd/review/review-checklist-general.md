# Review Checklist — General Software Projects

Use this checklist when Domain is `other` or not clearly detected.

## Correctness

- Requirements implemented as planned
- Edge cases handled or explicitly documented
- Error paths return actionable messages
- Backward compatibility assessed (if applicable)

## Security

- Input validation performed
- Access control and authorization checked
- Sensitive data exposure avoided
- Dependency and supply-chain risks considered

## Reliability & Performance

- Failure modes identified and handled
- Resource usage impact reviewed
- Performance regressions considered (hot paths)
- Timeouts/retries/circuit breakers assessed (if applicable)

## Testing

- Unit tests cover core behavior
- Integration tests cover critical flows
- Regression tests added for bug fixes
- Manual verification steps documented

## Operations & Maintainability

- Logging/observability impact reviewed
- Migration/rollout considerations documented (if applicable)
- Docs updated for behavior/config changes
- Follow-up items captured with clear ownership
