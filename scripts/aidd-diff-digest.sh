#!/usr/bin/env bash
# aidd-diff-digest.sh — Build compact digest from git diff.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AIDD_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
if [ "$(basename "$AIDD_ROOT")" = ".aidd-flow" ]; then
  GIT_ROOT="$(cd "$AIDD_ROOT/.." && pwd)"
else
  GIT_ROOT="$AIDD_ROOT"
fi

WORK_DIR="$AIDD_ROOT/aidd/work"
OUTPUT_FILE="$WORK_DIR/DIFF_DIGEST.md"
mkdir -p "$WORK_DIR"

if ! command -v git >/dev/null 2>&1 || [ ! -d "$GIT_ROOT/.git" ]; then
  echo "Git repository not detected" >&2
  exit 1
fi

CHANGED_FILES=$(git -C "$GIT_ROOT" diff --name-only)
if [ -z "$CHANGED_FILES" ]; then
  CHANGED_FILES=$(git -C "$GIT_ROOT" diff --cached --name-only)
fi

if [ -z "$CHANGED_FILES" ]; then
  {
    echo "# Diff Digest"
    echo
    echo "No local changes."
  } > "$OUTPUT_FILE"
  echo "$OUTPUT_FILE"
  exit 0
fi

TOTAL_FILES=$(printf '%s\n' "$CHANGED_FILES" | sed '/^$/d' | wc -l | tr -d ' ')

API_SIGNALS=$(git -C "$GIT_ROOT" diff -- . \
  | grep -E '^[+-].*(export |public |interface |type |function |class )' \
  | head -n 20 || true)

RISK_SIGNALS=$(git -C "$GIT_ROOT" diff -- . \
  | grep -Ei '^[+-].*(auth|token|secret|password|sql|migration|schema|permission|role|acl)' \
  | head -n 20 || true)

{
  echo "# Diff Digest"
  echo
  echo "## Scope"
  echo
  echo "- Changed files: ${TOTAL_FILES}"
  echo
  echo "## Files"
  echo
  printf '%s\n' "$CHANGED_FILES" | sed '/^$/d' | sed 's/^/- `/' | sed 's/$/`/'
  echo
  echo "## API / Interface Signals"
  echo
  if [ -n "$API_SIGNALS" ]; then
    printf '```diff\n%s\n```\n' "$API_SIGNALS"
  else
    echo "- No obvious API/interface signature changes detected."
  fi
  echo
  echo "## Risk Signals"
  echo
  if [ -n "$RISK_SIGNALS" ]; then
    printf '```diff\n%s\n```\n' "$RISK_SIGNALS"
  else
    echo "- No obvious high-risk keyword changes detected."
  fi
  echo
  echo "## Suggested Validation"
  echo
  echo "- bash scripts/aidd-check.sh"
  echo "- bash scripts/validate-plan.sh"
  echo "- bash scripts/review-check.sh"
} > "$OUTPUT_FILE"

echo "$OUTPUT_FILE"
