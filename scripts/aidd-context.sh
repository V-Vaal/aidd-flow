#!/bin/bash

# AIDD Context: Generate compact context bundle for LLMs
# Prints: repo tree (depth 3), git status, last 10 commits, key config files
# Designed to run from <project>/.cursor/scripts/ or scripts/ at repository root
#
# Usage:
#   aidd-context.sh [--verbose]
#   --verbose    Include full file contents and extended details

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse optional flags
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

# Detect if we're in a target project (.cursor/scripts/) or repository root (scripts/)
if [ "$(basename "$(dirname "$SCRIPT_DIR")")" = ".cursor" ]; then
    # Running from target project: <project>/.cursor/scripts/
    CURSOR_DIR="$(dirname "$SCRIPT_DIR")"
    PROJECT_ROOT="$(cd "$CURSOR_DIR/.." && pwd)"
else
    # Running from repository root: scripts/
    REPO_ROOT="$(dirname "$SCRIPT_DIR")"
    PROJECT_ROOT="$REPO_ROOT"
    CURSOR_DIR="$REPO_ROOT/.cursor"
fi

# Verify PROJECT_ROOT exists before changing directory
if [ ! -d "$PROJECT_ROOT" ]; then
    echo "Error: Project root directory does not exist: $PROJECT_ROOT"
    echo "  Script location: $SCRIPT_DIR"
    exit 1
fi

cd "$PROJECT_ROOT"

echo "=== AIDD Context Bundle ==="
echo ""
echo "Generated: $(date)"
echo "Project: $(basename "$PROJECT_ROOT")"
if [ "$VERBOSE" -eq 1 ]; then
    echo "Mode: verbose (full dump)"
else
    echo "Mode: concise (steps + key paths)"
fi
echo ""

# 1. Repository tree (depth 3)
if [ "$VERBOSE" -eq 1 ]; then
echo "=== Repository Structure (depth 3) ==="
if command -v tree &> /dev/null; then
    tree -L 3 -I 'node_modules|.git|__pycache__|target|dist|build' 2>/dev/null || find . -maxdepth 3 -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/__pycache__/*' -not -path '*/target/*' -not -path '*/dist/*' -not -path '*/build/*' | head -50 || true
else
    find . -maxdepth 3 -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/__pycache__/*' -not -path '*/target/*' -not -path '*/dist/*' -not -path '*/build/*' 2>/dev/null | head -50 || true
fi
echo ""
else
    echo "=== Repository Structure (key paths) ==="
    find . -maxdepth 2 -type f \( -name "*.md" -o -name "*.json" -o -name "*.toml" -o -name "*.yml" -o -name "*.yaml" \) 2>/dev/null | grep -v node_modules | grep -v .git | head -20 || true
    echo ""
fi

# 2. Git status
if [ -d ".git" ] && command -v git &> /dev/null; then
    if [ "$VERBOSE" -eq 1 ]; then
    echo "=== Git Status ==="
    git status --short 2>/dev/null || echo "(git status failed)"
    echo ""
    
    echo "=== Recent Commits (last 10) ==="
    git log --oneline -10 2>/dev/null || echo "(git log failed)"
    echo ""
    
    echo "=== Current Branch ==="
    git branch --show-current 2>/dev/null || echo "(git branch failed)"
    echo ""
else
        echo "=== Git Status ==="
        BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
        CHANGES=$(git status --short 2>/dev/null | wc -l | tr -d ' ' || echo "0")
        echo "Branch: $BRANCH, Uncommitted changes: $CHANGES"
        echo ""
    fi
else
    if [ "$VERBOSE" -eq 1 ]; then
    echo "=== Git Status ==="
    echo "Not a git repository or git not available"
    echo ""
    fi
fi

# 3. Key config files
if [ "$VERBOSE" -eq 1 ]; then
echo "=== Key Configuration Files ==="

# Package managers
[ -f "package.json" ] && echo "✓ package.json" && (head -20 "package.json" 2>/dev/null || echo "(read failed)")
[ -f "Cargo.toml" ] && echo "✓ Cargo.toml" && (head -20 "Cargo.toml" 2>/dev/null || echo "(read failed)")
[ -f "pyproject.toml" ] && echo "✓ pyproject.toml" && (head -20 "pyproject.toml" 2>/dev/null || echo "(read failed)")
[ -f "requirements.txt" ] && echo "✓ requirements.txt" && (head -10 "requirements.txt" 2>/dev/null || echo "(read failed)")
[ -f "Pipfile" ] && echo "✓ Pipfile" && (head -20 "Pipfile" 2>/dev/null || echo "(read failed)")

# Build configs
[ -f "tsconfig.json" ] && echo "✓ tsconfig.json"
[ -f "next.config.js" ] && echo "✓ next.config.js"
[ -f "next.config.ts" ] && echo "✓ next.config.ts"
[ -f "vite.config.js" ] && echo "✓ vite.config.js"
[ -f "vite.config.ts" ] && echo "✓ vite.config.ts"
[ -f "webpack.config.js" ] && echo "✓ webpack.config.js"
[ -f "hardhat.config.js" ] && echo "✓ hardhat.config.js"
[ -f "hardhat.config.ts" ] && echo "✓ hardhat.config.ts"
[ -f "foundry.toml" ] && echo "✓ foundry.toml"

# CI/CD
[ -d ".github/workflows" ] && echo "✓ .github/workflows/ (exists)"
[ -f ".gitlab-ci.yml" ] && echo "✓ .gitlab-ci.yml"

# Linting/formatting
[ -f ".eslintrc" ] && echo "✓ .eslintrc"
[ -f ".eslintrc.js" ] && echo "✓ .eslintrc.js"
[ -f ".eslintrc.json" ] && echo "✓ .eslintrc.json"
[ -f ".prettierrc" ] && echo "✓ .prettierrc"
[ -f ".prettierrc.js" ] && echo "✓ .prettierrc.js"
[ -f ".clippy.toml" ] && echo "✓ .clippy.toml"
[ -f "pyproject.toml" ] && echo "✓ pyproject.toml (may contain lint config)"

# Documentation
[ -f "README.md" ] && echo "✓ README.md (root)"
[ -f "CHANGELOG.md" ] && echo "✓ CHANGELOG.md (root)"
[ -f "docs/workflow.md" ] && echo "✓ docs/workflow.md"

echo ""
else
    echo "=== Key Configuration Files ==="
    CONFIG_FILES=()
    [ -f "package.json" ] && CONFIG_FILES+=("package.json")
    [ -f "Cargo.toml" ] && CONFIG_FILES+=("Cargo.toml")
    [ -f "pyproject.toml" ] && CONFIG_FILES+=("pyproject.toml")
    [ -f "requirements.txt" ] && CONFIG_FILES+=("requirements.txt")
    [ -d ".github/workflows" ] && CONFIG_FILES+=(".github/workflows/")
    [ -f "tsconfig.json" ] && CONFIG_FILES+=("tsconfig.json")
    [ -f "README.md" ] && CONFIG_FILES+=("README.md")
    
    if [ ${#CONFIG_FILES[@]} -gt 0 ]; then
        printf '%s\n' "${CONFIG_FILES[@]}"
    else
        echo "(none detected)"
    fi
    echo ""
fi

# 4. Project type detection
echo "=== Project Type Detection ==="
if [ -f "package.json" ]; then
    echo "Type: Node.js/TypeScript"
    if grep -q '"react"' "package.json" 2>/dev/null; then
        echo "  Framework: React"
    fi
    if grep -q '"next"' "package.json" 2>/dev/null; then
        echo "  Framework: Next.js"
    fi
    if grep -q '"hardhat"' "package.json" 2>/dev/null; then
        echo "  Tool: Hardhat"
    fi
fi

[ -f "Cargo.toml" ] && echo "Type: Rust"
[ -f "requirements.txt" ] && echo "Type: Python"
[ -f "pyproject.toml" ] && echo "Type: Python (modern)"

echo ""

# 5. AIDD template info
if [ -d ".cursor/rules" ]; then
    echo "=== AIDD Rules Available ==="
    RULES_COUNT=$(find ".cursor/rules" -name "*.mdc" -type f 2>/dev/null | wc -l | tr -d ' ' || echo "0")
    echo "Total rules: $RULES_COUNT"
    echo ""
elif [ -d "$CURSOR_DIR/rules" ]; then
    echo "=== AIDD Rules Available ==="
    RULES_COUNT=$(find "$CURSOR_DIR/rules" -name "*.mdc" -type f 2>/dev/null | wc -l | tr -d ' ' || echo "0")
    echo "Total rules: $RULES_COUNT"
    echo ""
fi

# 6. Memory Bank
# Context-size design: Memory Bank files are core project knowledge
# In concise mode: show informational line if present
# In verbose mode: include full contents for detailed context
MEMORY_DIR=""
if [ -d ".cursor/memory" ]; then
    MEMORY_DIR=".cursor/memory"
elif [ -d "$CURSOR_DIR/memory" ]; then
    MEMORY_DIR="$CURSOR_DIR/memory"
fi

if [ -n "$MEMORY_DIR" ]; then
    if [ "$VERBOSE" -eq 1 ]; then
        # Verbose mode: full dump
        echo "=== Memory Bank ==="
        
        # Include core memory files if present
        MEMORY_FILES=(
            "projectbrief.md"
            "techContext.md"
            "systemPatterns.md"
            "activeContext.md"
        )
        
        for mem_file in "${MEMORY_FILES[@]}"; do
            if [ -f "$MEMORY_DIR/$mem_file" ]; then
                echo ""
                echo "--- $mem_file ---"
                cat "$MEMORY_DIR/$mem_file" 2>/dev/null || echo "(read failed)"
            fi
        done
        echo ""
    else
        # Concise mode: informational line only
        MEMORY_FILES=(
            "projectbrief.md"
            "techContext.md"
            "systemPatterns.md"
            "activeContext.md"
        )
        
        MEMORY_COUNT=0
        for mem_file in "${MEMORY_FILES[@]}"; do
            if [ -f "$MEMORY_DIR/$mem_file" ]; then
                MEMORY_COUNT=$((MEMORY_COUNT + 1))
            fi
        done
        
        if [ "$MEMORY_COUNT" -gt 0 ]; then
            printf "Memory Bank: present (%d file" "$MEMORY_COUNT"
            if [ "$MEMORY_COUNT" -eq 1 ]; then
                printf ") — use --verbose to inspect\n"
            else
                printf "s) — use --verbose to inspect\n"
            fi
            echo ""
        fi
    fi
fi

# 7. Work/Review Artefacts (bounded inclusion)
# Context-size design: Only include current work artefacts, not historical/accumulated files
# This keeps context focused on active work while preventing unbounded growth
WORK_DIR=""
if [ -d ".cursor/work" ]; then
    WORK_DIR=".cursor/work"
elif [ -d "$CURSOR_DIR/work" ]; then
    WORK_DIR="$CURSOR_DIR/work"
fi

if [ -n "$WORK_DIR" ]; then
    if [ "$VERBOSE" -eq 1 ]; then
    echo "=== Work Artefacts (Current) ==="
    
    # Include current work files if present (not historical)
    WORK_FILES=(
        "INTAKE.md"
        "PLAN.md"
        "REVIEW.md"
        "CHECKLIST.md"
    )
    
    for work_file in "${WORK_FILES[@]}"; do
        if [ -f "$WORK_DIR/$work_file" ]; then
            echo ""
            echo "--- $work_file ---"
            # Limit size: show first 100 lines to prevent unbounded context
            head -100 "$WORK_DIR/$work_file" 2>/dev/null || echo "(read failed)"
            LINE_COUNT=$(wc -l < "$WORK_DIR/$work_file" 2>/dev/null | tr -d ' ' || echo "0")
            if [ "$LINE_COUNT" -gt 100 ]; then
                echo ""
                echo "... (truncated, $LINE_COUNT total lines)"
            fi
        fi
    done
    echo ""
    else
        echo "=== Work Artefacts ==="
        WORK_FILES=("INTAKE.md" "PLAN.md" "REVIEW.md" "CHECKLIST.md")
        for work_file in "${WORK_FILES[@]}"; do
            if [ -f "$WORK_DIR/$work_file" ]; then
                # Extract key info: Status, Change Class, Goal (first line after ## Goal)
                STATUS=$(grep -iE "^\*\*Artefact Status\*\*" "$WORK_DIR/$work_file" 2>/dev/null | head -1 | sed 's/.*\*\*Artefact Status\*\*[[:space:]]*:[[:space:]]*//' | cut -d'|' -f1 | tr -d ' ' || echo "")
                CLASS=$(grep -iE "^\*\*Change Class\*\*" "$WORK_DIR/$work_file" 2>/dev/null | head -1 | sed 's/.*\*\*Change Class\*\*[[:space:]]*:[[:space:]]*//' | cut -d'|' -f1 | tr -d ' ' || echo "")
                GOAL=$(awk '/^## Goal/,/^## / {if (/^## Goal/) next; if (/^## /) exit; print}' "$WORK_DIR/$work_file" 2>/dev/null | head -1 | sed 's/^\[//;s/\]$//' | cut -c1-50 || echo "")
                echo "  $work_file: Status=$STATUS Class=$CLASS Goal=$GOAL"
            fi
        done
        echo ""
    fi
fi

# 8. Review Checklists (domain-specific)
# Context-size design: Include review checklists as reference, but limit to current domain
# This provides relevant security/quality guidance without overwhelming context
REVIEW_DIR=""
if [ -d ".cursor/review" ]; then
    REVIEW_DIR=".cursor/review"
elif [ -d "$CURSOR_DIR/review" ]; then
    REVIEW_DIR="$CURSOR_DIR/review"
fi

if [ -n "$REVIEW_DIR" ]; then
    # Only include if there are checklist files (avoid empty section)
    CHECKLIST_COUNT=$(find "$REVIEW_DIR" -name "review-checklist-*.md" -type f 2>/dev/null | wc -l | tr -d ' ' || echo "0")
    if [ "$CHECKLIST_COUNT" -gt 0 ]; then
        echo "=== Review Checklists Available ==="
        find "$REVIEW_DIR" -name "review-checklist-*.md" -type f 2>/dev/null -print0 | while IFS= read -r -d '' checklist; do
            echo "  - $(basename "$checklist")"
        done
        echo ""
    fi
fi

echo "=== End of Context Bundle ==="
