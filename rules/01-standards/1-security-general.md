# 1 security general

Secrets and Credentials:
- Never commit secrets to version control
- Use environment variables or secure vaults for secrets
- Validate secret presence at startup
- Rotate secrets regularly
- Never log secrets or credentials
- Use different secrets per environment

Input Validation:
- Validate all external inputs strictly
- Reject invalid input early
- Use allowlists over denylists when possible
- Validate data types and ranges
- Sanitize user-provided strings
- Enforce maximum input lengths
- Validate file uploads and sizes

Authentication and Authorization:
- Verify signatures and tokens before processing
- Use strong cryptographic primitives
- Implement proper session management
- Enforce principle of least privilege
- Validate permissions at every boundary
- Use time-limited tokens when applicable
- Never trust client-side validation alone

Safe Logging:
- Never log sensitive data (passwords, tokens, keys)
- Sanitize user data before logging
- Use structured logging with appropriate levels
- Avoid logging full request/response bodies
- Log security events (auth failures, privilege escalations)
- Use error codes instead of detailed error messages

Dependency Hygiene:
- Keep dependencies up to date
- Audit dependencies for known vulnerabilities
- Prefer well-maintained, audited packages
- Pin dependency versions explicitly
- Review dependency changes in PRs
- Remove unused dependencies

Error Handling:
- Never expose internal errors to users
- Return generic error messages to clients
- Log detailed errors server-side only
- Fail securely on errors
- Use custom error types for security events
- Avoid error messages that leak system information

Least Privilege:
- Grant minimum permissions required
- Use role-based access control when applicable
- Separate read and write permissions
- Review permission changes carefully
- Revoke unused permissions promptly
- Audit access regularly
