#!/usr/bin/env bash
# aidd-rules-jit.sh — Select minimal relevant rules for current task.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AIDD_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
if [ "$(basename "$AIDD_ROOT")" = ".aidd-flow" ]; then
  PROJECT_ROOT="$(cd "$AIDD_ROOT/.." && pwd)"
else
  PROJECT_ROOT="$AIDD_ROOT"
fi

WORK_DIR="$AIDD_ROOT/aidd/work"
TECH_CONTEXT="$AIDD_ROOT/aidd/memory/techContext.md"
OUTPUT_FILE="$WORK_DIR/RULES_JIT.md"
CONTEXT_BUDGET="${CONTEXT_BUDGET:-low}"

mkdir -p "$WORK_DIR"

RULES=(
  "00-master-workflow.md"
  "01-standards/1-clean-code.md"
  "01-standards/1-naming-conventions.md"
  "01-standards/1-security-general.md"
  "05-workflows-and-processes/5-aidd-loop.md"
  "04-tools-and-configurations/4-gh-and-docs.md"
)

if [ -f "$PROJECT_ROOT/package.json" ]; then
  RULES+=("02-programming-languages/2-typescript.md" "02-programming-languages/2-typescript-naming-conventions.md")
  if grep -qi '"react"' "$PROJECT_ROOT/package.json" 2>/dev/null; then
    RULES+=("03-frameworks-and-libraries/3-react.md")
  fi
  if grep -qi '"viem"' "$PROJECT_ROOT/package.json" 2>/dev/null; then
    RULES+=("03-frameworks-and-libraries/3-viem.md")
  fi
  if grep -qi '"wagmi"' "$PROJECT_ROOT/package.json" 2>/dev/null; then
    RULES+=("03-frameworks-and-libraries/3-wagmi@3.md")
  fi
fi

if [ -f "$PROJECT_ROOT/requirements.txt" ] || [ -f "$PROJECT_ROOT/pyproject.toml" ]; then
  RULES+=("02-programming-languages/2-python.md")
fi

if [ -f "$PROJECT_ROOT/Cargo.toml" ]; then
  RULES+=("02-programming-languages/2-rust.md")
fi

DOMAIN="other"
if [ -f "$TECH_CONTEXT" ]; then
  if grep -qiE 'domain.*web3|solidity|ethereum|blockchain' "$TECH_CONTEXT"; then
    DOMAIN="web3"
  elif grep -qiE 'domain.*ml|machine learning|pytorch|tensorflow' "$TECH_CONTEXT"; then
    DOMAIN="ml"
  elif grep -qiE 'domain.*mixed' "$TECH_CONTEXT"; then
    DOMAIN="mixed"
  fi
fi

case "$DOMAIN" in
  web3)
    RULES+=("08-domain-specific-rules/8-web3-security-patterns.md" "08-domain-specific-rules/8-smart-contract-testing.md")
    ;;
  ml)
    RULES+=("02-programming-languages/2-python-ml.md" "08-domain-specific-rules/8-ml-experimentation.md")
    ;;
  mixed)
    RULES+=("08-domain-specific-rules/8-web3-security-patterns.md" "08-domain-specific-rules/8-ml-experimentation.md")
    ;;
  *)
    ;;
esac

# Deduplicate while preserving order.
declare -A seen
SELECTED=()
for rule in "${RULES[@]}"; do
  if [ -n "${seen[$rule]:-}" ]; then
    continue
  fi
  seen[$rule]=1
  SELECTED+=("$rule")
done

# Medium/high budgets can include broader QA rules.
if [ "$CONTEXT_BUDGET" = "medium" ] || [ "$CONTEXT_BUDGET" = "high" ]; then
  SELECTED+=("07-quality-assurance/7-testing-standards.md")
fi
if [ "$CONTEXT_BUDGET" = "high" ]; then
  SELECTED+=("07-quality-assurance/7-tests-integration.md" "07-quality-assurance/7-tests-units.md")
fi

{
  echo "# Rules JIT Selection"
  echo
  echo "- Context budget: ${CONTEXT_BUDGET}"
  echo "- Detected domain: ${DOMAIN}"
  echo
  echo "## Load These Rules"
  echo
  for rule in "${SELECTED[@]}"; do
    echo "- \\`rules/${rule}\\`"
  done
} > "$OUTPUT_FILE"

echo "$OUTPUT_FILE"
