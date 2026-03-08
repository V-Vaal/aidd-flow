# Tooling Notes — External Information Access

## Available workflow scripts

- `scripts/gh-context.sh` — GitHub signals via `gh` CLI (facts-only JSON)
- `scripts/c7-docs.sh` — library documentation via Context7 (`curl`)
- `scripts/aidd-rules-jit.sh` — just-in-time rules selection
- `scripts/aidd-diff-digest.sh` — compact diff digest

## Operational rules

- Use `gh-context.sh` for GitHub issue/PR context.
- Use `c7-docs.sh` before coding against external library APIs.
- Context7 evidence is recorded in `aidd/work/SUMMARY.md` and required by `aidd-check.sh`.

## Context7 usage

```bash
bash scripts/c7-docs.sh --library reactjs/react.dev --topic hooks --tokens 2000
bash scripts/c7-docs.sh --library wevm/wagmi --topic useAccount --tokens 3000
```

Notes:
- Output is markdown content suitable for direct LLM context.
- Responses are cached under `cache/context7/` with TTL (`C7_CACHE_TTL_SECONDS`).
- Topics containing spaces are normalized automatically.
