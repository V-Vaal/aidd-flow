# 5 ci cd standards

Lint and Typecheck Gates:
- Run linters as separate job steps
- Fail build on linting errors
- Run type checkers before tests
- Use consistent linting configuration
- Check formatting in CI
- Fail on type errors
- Report linting results clearly

Test Gates:
- Run all tests in CI
- Fail build on test failures
- Run tests in parallel when possible
- Use test coverage thresholds
- Report test results clearly
- Run tests on multiple environments
- Include integration tests in CI

Dependency Audit:
- Audit dependencies for vulnerabilities
- Fail build on critical vulnerabilities
- Update dependencies regularly
- Pin dependency versions
- Review dependency changes in PRs
- Use automated dependency updates
- Document dependency update process

Secret Scanning:
- Scan for secrets in code
- Fail build on secret detection
- Use secret scanning tools
- Check commit history for secrets
- Validate environment variables
- Never commit secrets to repository
- Rotate exposed secrets immediately

Minimal Build Steps:
- Keep build steps focused and minimal
- Avoid unnecessary build steps
- Cache build artifacts when possible
- Use build matrix only when needed
- Parallelize independent build steps
- Optimize build time
- Document build requirements

Caching Guidance:
- Cache dependencies between runs
- Cache build artifacts appropriately
- Use cache keys that include versions
- Invalidate caches when dependencies change
- Cache test results when applicable
- Monitor cache hit rates
- Document caching strategy

Fail-Fast Principles:
- Fail early on configuration errors
- Stop pipeline on critical failures
- Run fast checks before slow ones
- Parallelize independent checks
- Use conditional steps when appropriate
- Report failures clearly
- Minimize wait time for failures

Rules Validation:
- Run rules validation script in CI
- Validate Cursor rules structure and frontmatter
- Fail build on rules validation errors
- Use scripts/validate-rules.sh for validation
- Example GitHub Actions step:
  ```yaml
  - name: Validate Cursor Rules
    run: |
      bash scripts/validate-rules.sh
  ```
