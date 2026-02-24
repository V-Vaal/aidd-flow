# Debugging

## Debug Loop

Systematic debugging workflow:

```
Reproduce → Isolate → Instrument → Minimal Case → Fix → Regression → Verify
```

**1. Reproduce:**
- Make the bug happen consistently
- Document exact steps to reproduce
- Note environment details (OS, browser, versions)
- Capture error messages and stack traces

**2. Isolate:**
- Identify the minimal code path that triggers the bug
- Remove unrelated code to isolate
- Check if it's a data issue or code issue
- Verify if it's a timing/race condition

**3. Add Instrumentation:**
- Add debug logs at key points
- Log input values and state
- Log intermediate results
- Use structured logging

**4. Create Minimal Failing Case:**
- Remove all non-essential code
- Create a minimal test case
- Verify it still reproduces the bug

**5. Fix:**
- Understand root cause
- Implement fix in minimal case
- Apply fix to full codebase
- Review fix for side effects

**6. Regression Tests:**
- Add test for the bug scenario
- Add test for edge cases
- Run full test suite
- Verify no regressions introduced

**7. Verification:**
- Reproduce original issue - should be fixed
- Test related scenarios
- Test edge cases
- Monitor for related issues

## UI Bugs: Browser Verification

For frontend issues, always verify in browser:
- Reproduce in actual browser (not just tests)
- Check browser console for errors
- Check network tab for failed requests
- Verify in multiple browsers if needed
- Test responsive behavior
- Check accessibility (a11y) if relevant
