# Web3 Security Review Checklist

## Access Control

- [ ] All privileged functions are protected with access control modifiers
- [ ] Role-based access control (RBAC) is properly implemented
- [ ] Owner/admin functions are clearly identified and limited
- [ ] Access control changes are logged/emitted via events

## Reentrancy Protection

- [ ] External calls follow checks-effects-interactions pattern
- [ ] ReentrancyGuard is used where appropriate
- [ ] State changes occur before external calls
- [ ] No recursive call paths through external contracts

## External Calls

- [ ] All external calls are validated and handled safely
- [ ] Low-level calls (call/delegatecall) are used with extreme caution
- [ ] Return values from external calls are checked
- [ ] Failed external calls are handled gracefully

## Events

- [ ] Critical state changes emit events
- [ ] Events include all relevant parameters
- [ ] Event parameters are indexed appropriately for filtering

## Input Validation

- [ ] All user inputs are validated (bounds, types, formats)
- [ ] Zero address checks are performed where needed
- [ ] Array length limits are enforced
- [ ] Integer overflow/underflow protection (SafeMath or Solidity 0.8+)

## DOS / Gas Risks

- [ ] Loops have bounded iterations
- [ ] Gas costs are reasonable for all operations
- [ ] No unbounded external calls in loops
- [ ] Storage operations are optimized

## Oracle / Price Dependency

- [ ] Oracle price feeds are validated and secure
- [ ] Price staleness checks are implemented
- [ ] Multiple oracle sources considered (if applicable)
- [ ] Price manipulation risks are mitigated

## Upgradeability (if applicable)

- [ ] Upgrade mechanism is secure and tested
- [ ] Storage layout compatibility is maintained
- [ ] Upgrade permissions are properly restricted
- [ ] Initialization functions are protected

## Invariant / Property-Based Tests

- [ ] Critical invariants are tested
- [ ] Property-based tests cover edge cases
- [ ] Fuzzing tests are included for complex logic
- [ ] Formal verification considered (if applicable)
