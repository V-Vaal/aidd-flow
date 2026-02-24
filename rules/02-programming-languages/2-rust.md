# 2 rust

Clippy and Formatting:
- Run clippy before committing
- Fix all clippy warnings
- Use rustfmt for code formatting
- Configure rustfmt consistently
- Run clippy with pedantic lints
- Address clippy suggestions
- Keep code formatted automatically

Error Handling:
- Use Result types for fallible operations
- Prefer thiserror for library error types
- Consider anyhow for application errors
- Never ignore errors with unwrap in production
- Handle errors explicitly
- Provide meaningful error messages
- Chain errors with context

Avoiding Unwrap in Production:
- Use expect with descriptive messages
- Use unwrap only in tests or unreachable code
- Handle Option and Result explicitly
- Use match or if let for Option handling
- Provide fallback behavior when possible
- Log errors before unwrapping in development
- Never unwrap user input

Lifetime and Ownership:
- Make lifetime parameters explicit when needed
- Use borrowing over ownership when possible
- Document lifetime requirements clearly
- Avoid unnecessary clones
- Use references for read-only access
- Understand ownership transfer
- Use Rc or Arc for shared ownership

Logging:
- Use structured logging
- Log errors with appropriate levels
- Include context in log messages
- Use log levels consistently
- Never log sensitive data
- Log important state changes
- Use tracing for async code

Security Basics:
- Validate all external inputs
- Use safe cryptographic libraries
- Never hardcode secrets
- Handle sensitive data carefully
- Use secure random number generators
- Validate buffer sizes
- Review unsafe code carefully
