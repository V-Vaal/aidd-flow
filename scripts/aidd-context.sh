#!/bin/bash

# AIDD Context: generate a compact context bundle for LLM sessions.
# Usage:
#   aidd-context.sh [--verbose]
# Env:
#   CONTEXT_BUDGET=low|medium|high (default: low)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AIDD_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
if [ "$(basename "$AIDD_ROOT")" = ".aidd-flow" ]; then
    PROJECT_ROOT="$(cd "$AIDD_ROOT/.." && pwd)"
else
    PROJECT_ROOT="$AIDD_ROOT"
fi

MEMORY_DIR="$AIDD_ROOT/aidd/memory"
WORK_DIR="$AIDD_ROOT/aidd/work"
RULES_DIR="$AIDD_ROOT/rules"

VERBOSE=0
for arg in "$@"; do
    case "$arg" in
        --verbose)
            VERBOSE=1
            ;;
        *)
            echo "Unknown flag: $arg"
            echo "Usage: $0 [--verbose]"
            exit 1
            ;;
    esac
done

CONTEXT_BUDGET="${CONTEXT_BUDGET:-low}"
case "$CONTEXT_BUDGET" in
    low|medium|high) ;;
    *) CONTEXT_BUDGET="low" ;;
esac

if [ "$VERBOSE" -eq 1 ]; then
    CONTEXT_BUDGET="high"
fi

cd "$PROJECT_ROOT"

echo "=== AIDD Context Bundle ==="
echo ""
echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "Project: $(basename "$PROJECT_ROOT")"
echo "Context budget: $CONTEXT_BUDGET"
echo ""

print_compact_tree() {
    if command -v tree >/dev/null 2>&1; then
        tree -L 2 -I 'node_modules|.git|__pycache__|target|dist|build|.cache' 2>/dev/null || true
    else
        find . -maxdepth 2 -not -path '*/node_modules/*' -not -path '*/.git/*' | head -80 || true
    fi
}

print_medium_tree() {
    if command -v tree >/dev/null 2>&1; then
        tree -L 3 -I 'node_modules|.git|__pycache__|target|dist|build|.cache' 2>/dev/null || true
    else
        find . -maxdepth 3 -not -path '*/node_modules/*' -not -path '*/.git/*' | head -140 || true
    fi
}

echo "=== Repo Shape ==="
if [ "$CONTEXT_BUDGET" = "low" ]; then
    print_compact_tree
else
    print_medium_tree
fi
echo ""

if [ -d .git ] && command -v git >/dev/null 2>&1; then
    echo "=== Git Snapshot ==="
    echo "Branch: $(git branch --show-current 2>/dev/null || echo unknown)"
    echo "Changes: $(git status --short 2>/dev/null | wc -l | tr -d ' ')"
    if [ "$CONTEXT_BUDGET" != "low" ]; then
        echo "Recent commits:"
        git log --oneline -10 2>/dev/null || true
    fi
    echo ""
fi

echo "=== Key Artefacts ==="
for f in "$WORK_DIR/SUMMARY.md" "$WORK_DIR/HANDOFF.md" "$WORK_DIR/DIFF_DIGEST.md" "$WORK_DIR/RULES_JIT.md"; do
    if [ -f "$f" ]; then
        echo "- $(basename "$f")"
    fi
done
echo ""

if [ -f "$WORK_DIR/SUMMARY.md" ]; then
    echo "=== SUMMARY.md (priority) ==="
    head -80 "$WORK_DIR/SUMMARY.md"
    echo ""
fi

if [ -f "$WORK_DIR/HANDOFF.md" ] && [ "$CONTEXT_BUDGET" != "low" ]; then
    echo "=== HANDOFF.md ==="
    head -120 "$WORK_DIR/HANDOFF.md"
    echo ""
fi

if [ -f "$WORK_DIR/DIFF_DIGEST.md" ] && [ "$CONTEXT_BUDGET" != "low" ]; then
    echo "=== DIFF_DIGEST.md ==="
    head -120 "$WORK_DIR/DIFF_DIGEST.md"
    echo ""
fi

if [ -d "$MEMORY_DIR" ]; then
    echo "=== Memory ==="
    for f in projectbrief.md techContext.md systemPatterns.md activeContext.md tooling-notes.md; do
        if [ -f "$MEMORY_DIR/$f" ]; then
            if [ "$CONTEXT_BUDGET" = "high" ]; then
                echo "--- $f ---"
                head -140 "$MEMORY_DIR/$f"
            else
                echo "- $f"
            fi
        fi
    done
    echo ""
fi

if [ -d "$RULES_DIR" ]; then
    echo "=== Rules ==="
    count=$(find "$RULES_DIR" -name '*.md' -type f | wc -l | tr -d ' ')
    echo "Total rules: $count"
    if [ -f "$WORK_DIR/RULES_JIT.md" ]; then
      echo "JIT selection available: $WORK_DIR/RULES_JIT.md"
      if [ "$CONTEXT_BUDGET" != "low" ]; then
          head -80 "$WORK_DIR/RULES_JIT.md"
      fi
    fi
    echo ""
fi

echo "=== End of Context Bundle ==="
