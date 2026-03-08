# Rule: GitHub signals and external library docs

## gh-context.sh — GitHub signals

Use during Architect phase to fetch GitHub context before solution design.

Use cases:
- open issues/PR snapshots
- facts for a specific issue or PR
- labels/state context for planning

Commands:

```bash
bash scripts/gh-context.sh issues-open
bash scripts/gh-context.sh issue 42
bash scripts/gh-context.sh prs-open
bash scripts/gh-context.sh pr 17
```

Output must remain JSON and facts-only.

## c7-docs.sh — Context7 library documentation

Use during Architect and early Editor phases before coding against external library APIs.

Commands:

```bash
bash scripts/c7-docs.sh --library reactjs/react.dev --topic hooks --tokens 2000
bash scripts/c7-docs.sh --library wevm/wagmi --topic useAccount --tokens 3000
```

Token guidance:
- `2000`: general usage and concept overview
- `3000-4000`: complex APIs with many signatures

## Requirements

- GitHub signals must use `gh-context.sh`.
- External library docs must use `c7-docs.sh`.
- Keep outputs concise and directly consumable by LLM workflows.
