# 8 solidity security core

Security Invariants:
- No untrusted external input may affect core accounting without validation
- No external call may occur before all critical state is finalized
- No privileged action may occur without explicit authorization
- No accounting invariant may be temporarily violated
- Enforce invariants at contract boundaries
- Document all critical invariants explicitly

Reentrancy Protection:
- Use ReentrancyGuard for state-changing external calls
- Apply checks-effects-interactions pattern strictly
- Update state before external calls when possible
- Use nonReentrant modifier for critical functions
- Be extra careful with callbacks and hooks
- Consider reentrancy in cross-function flows

Access Control:
- Implement role-based access control explicitly
- Use OpenZeppelin AccessControl when applicable
- Verify permissions at function entry
- Never rely on implicit access assumptions
- Use modifiers for access checks consistently
- Document admin and privileged functions clearly
- Secure initializer and constructor functions properly
- Consider admin key risk and rotation assumptions
- Separate protocol admin roles from operational roles
- Never grant excessive permissions to single addresses

Checks-Effects-Interactions Pattern:
- Perform all checks first
- Update all state variables next
- Make external calls last
- Never mix state updates with external calls
- Document deviations from this pattern

External Calls:
- Validate external call targets before calling
- Handle external call failures explicitly
- Use low-level calls (call/delegatecall) with caution
- Handle return values from ERC20 transfers explicitly
- Account for non-standard token behaviors
- Consider fee-on-transfer and rebasing token risks
- Be aware of callback and hook patterns (ERC777-style)
- Treat callbacks and hooks as reentrancy vectors
- Never trust return values from external calls
- Consider gas limits for external calls
- Be aware of proxy patterns and delegatecall risks

Custom Errors:
- Use custom errors instead of require strings
- Make error messages descriptive but not verbose
- Group related errors logically
- Use custom errors for gas efficiency

Events:
- Emit events for all state-changing operations
- Include relevant parameters in event data
- Use indexed parameters for filtering
- Emit events before external calls when possible

Pausing and Emergency Patterns:
- Implement pausable pattern for critical functions
- Use timelock for admin operations when appropriate
- Provide emergency withdrawal mechanisms
- Document emergency procedures clearly
- Test emergency scenarios thoroughly

Upgradeability Awareness:
- Upgradeability is optional; use only when needed
- When using upgradeability, version storage layout explicitly
- Never change storage variable order
- Use storage gaps for future extensibility
- Review storage layout changes carefully
- Be cautious with delegatecall and proxies
- Treat upgrade functions as privileged attack surfaces
- Test upgrade paths comprehensively
- Document upgrade risks and limitations

Integer and Decimal Safety:
- Use SafeMath patterns or Solidity 0.8+ built-in checks
- Be aware of overflow/underflow risks
- Use appropriate precision for decimals
- Validate ranges before arithmetic operations
- Consider rounding errors in calculations
- Use fixed-point math libraries when needed

Safe Accounting:
- Maintain accounting invariants strictly
- Use checksums for balance verification
- Never allow negative balances
- Validate amounts before transfers
- Handle fee-on-transfer tokens explicitly
- Track total supply and balances consistently
- Test edge cases around zero values

MEV and Frontrunning:
- Be aware of price manipulation risks
- Consider sandwich attack vectors
- Avoid reliance on block.timestamp for critical logic
- Be cautious with block.number for time-dependent operations
- Design mechanisms to reduce MEV extraction
- Consider commit-reveal schemes when appropriate
- Document assumptions about block-level timing

Invariants:
- Document and enforce critical invariants
- Add invariant checks in tests
- Verify invariants after state changes
- Use fuzzing to discover invariant violations
- Consider formal verification for critical contracts

General Security Mindset:
- Assume external actors are adversarial
- Validate all inputs from external sources
- Never trust external contract state
- Consider front-running and MEV risks
- Be aware of gas griefing vectors
- Design for failure and edge cases
- Review code with security-first mindset
- Prefer simplicity over clever optimizations
