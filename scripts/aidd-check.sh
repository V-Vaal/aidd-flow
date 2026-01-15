#!/bin/bash

# AIDD Check: Comprehensive validation script
# Runs: validate-rules + lint/test hooks if detected
# Optional flags: --plan (validate PLAN.md), --review (validate REVIEW.md)
# Prints next actions
# Designed to run from <project>/.cursor/scripts/ or template/scripts/
#
# Usage:
#   aidd-check.sh [--plan] [--review]
#   --plan    Validate PLAN.md before proceeding (optional, does not fail if missing)
#   --review  Validate REVIEW.md and suggest domain checklists (optional)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors (define early for usage in flag parsing)
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Parse optional flags
CHECK_PLAN=0
CHECK_REVIEW=0
for arg in "$@"; do
    case "$arg" in
        --plan)
            CHECK_PLAN=1
            ;;
        --review)
            CHECK_REVIEW=1
            ;;
        *)
            echo -e "${YELLOW}Unknown flag: $arg${NC}"
            echo "Usage: $0 [--plan] [--review]"
            exit 1
            ;;
    esac
done

# Detect if we're in a target project (.cursor/scripts/) or template (template/scripts/)
IS_TEMPLATE_MODE=0
if [ "$(basename "$(dirname "$SCRIPT_DIR")")" = ".cursor" ]; then
    # Running from target project: <project>/.cursor/scripts/
    CURSOR_DIR="$(dirname "$SCRIPT_DIR")"
    PROJECT_ROOT="$(cd "$CURSOR_DIR/.." && pwd)"
else
    # Running from template: template/scripts/
    IS_TEMPLATE_MODE=1
    TEMPLATE_DIR="$(dirname "$SCRIPT_DIR")"
    PROJECT_ROOT="$(cd "$TEMPLATE_DIR/.." && pwd)"
    CURSOR_DIR="$TEMPLATE_DIR/.cursor"
fi

# Verify PROJECT_ROOT exists before changing directory (only in target project mode)
if [ "$IS_TEMPLATE_MODE" -eq 0 ]; then
    if [ ! -d "$PROJECT_ROOT" ]; then
        echo -e "${RED}Error: Project root directory does not exist: $PROJECT_ROOT${NC}"
        echo -e "${RED}  Script location: $SCRIPT_DIR${NC}"
        exit 1
    fi
fi

ERRORS=0
WARNINGS=0

echo -e "${BLUE}=== AIDD Check ===${NC}"
echo ""

# Template mode: only validate template structure
if [ "$IS_TEMPLATE_MODE" -eq 1 ]; then
    echo -e "${BLUE}[Template Mode] Validating AIDD template structure...${NC}"
    echo -e "${YELLOW}template mode: project lint/tests skipped${NC}"
    echo ""
    
    # 1. Validate template rules
    echo -e "${BLUE}[1/2] Validating template rules...${NC}"
    VALIDATE_SCRIPT="$SCRIPT_DIR/validate-rules.sh"
    if [ -f "$VALIDATE_SCRIPT" ]; then
        if bash "$VALIDATE_SCRIPT"; then
            echo -e "${GREEN}✓ Rules validation passed${NC}"
        else
            echo -e "${RED}✗ Rules validation failed${NC}"
            echo -e "${YELLOW}  To rerun validation: bash template/scripts/validate-rules.sh${NC}"
            echo -e "${YELLOW}  Check template/.cursor/rules/ for issues${NC}"
            ERRORS=$((ERRORS + 1))
        fi
    else
        echo -e "${YELLOW}SKIP: validate-rules.sh not found at $VALIDATE_SCRIPT${NC}"
        echo -e "${YELLOW}  Reason: Script missing from expected location${NC}"
        WARNINGS=$((WARNINGS + 1))
    fi
    echo ""
    
    # 2. Verify expected scripts exist
    echo -e "${BLUE}[2/2] Verifying expected scripts...${NC}"
    EXPECTED_SCRIPTS=("validate-rules.sh" "validate-plan.sh" "review-check.sh" "aidd-export.sh" "aidd-context.sh" "aidd-verify-ui.sh" "aidd-check.sh")
    for script_name in "${EXPECTED_SCRIPTS[@]}"; do
        script_path="$SCRIPT_DIR/$script_name"
        if [ -f "$script_path" ]; then
            echo -e "${GREEN}  ✓ $script_name${NC}"
        else
            echo -e "${YELLOW}  ⚠ $script_name not found${NC}"
            WARNINGS=$((WARNINGS + 1))
        fi
    done
    echo ""
    
    # Summary for template mode
    echo -e "${BLUE}=== Summary ===${NC}"
    echo ""
    if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
        echo -e "${GREEN}✓ Template validation passed!${NC}"
        echo -e "${GREEN}OK${NC}"
        exit 0
    elif [ $ERRORS -eq 0 ]; then
        echo -e "${YELLOW}✓ Template validation passed with ${WARNINGS} warning(s)${NC}"
        echo -e "${GREEN}OK${NC}"
        exit 0
    else
        echo -e "${RED}✗ Template validation failed: ${ERRORS} error(s), ${WARNINGS} warning(s)${NC}"
        exit 1
    fi
fi

# Target project mode: full validation
cd "$PROJECT_ROOT"

# 1. Validate INTAKE.md (if exists)
INTAKE_FILE="$CURSOR_DIR/work/INTAKE.md"
if [ -f "$INTAKE_FILE" ]; then
    echo -e "${BLUE}[1/5] Validating INTAKE.md...${NC}"
    VALIDATE_INTAKE_SCRIPT="$SCRIPT_DIR/validate-intake.sh"
    if [ -f "$VALIDATE_INTAKE_SCRIPT" ]; then
        if bash "$VALIDATE_INTAKE_SCRIPT"; then
            echo -e "${GREEN}✓ INTAKE.md validation passed${NC}"
        else
            echo -e "${RED}✗ INTAKE.md validation failed${NC}"
            echo -e "${YELLOW}  To rerun validation: bash .cursor/scripts/validate-intake.sh${NC}"
            echo -e "${YELLOW}  Check .cursor/work/INTAKE.md for missing or empty sections${NC}"
            ERRORS=$((ERRORS + 1))
        fi
    else
        echo -e "${YELLOW}SKIP: validate-intake.sh not found${NC}"
        WARNINGS=$((WARNINGS + 1))
    fi
    echo ""
fi

# 2. Validate rules
echo -e "${BLUE}[2/5] Validating Cursor rules...${NC}"
VALIDATE_SCRIPT="$SCRIPT_DIR/validate-rules.sh"
if [ -f "$VALIDATE_SCRIPT" ]; then
    if bash "$VALIDATE_SCRIPT"; then
        echo -e "${GREEN}✓ Rules validation passed${NC}"
    else
        echo -e "${RED}✗ Rules validation failed${NC}"
        echo -e "${YELLOW}  To rerun validation: bash .cursor/scripts/validate-rules.sh${NC}"
        echo -e "${YELLOW}  Check .cursor/rules/ for issues${NC}"
        ERRORS=$((ERRORS + 1))
    fi
else
    echo -e "${YELLOW}SKIP: validate-rules.sh not found at $VALIDATE_SCRIPT${NC}"
    echo -e "${YELLOW}  Reason: Script missing from expected location${NC}"
    WARNINGS=$((WARNINGS + 1))
fi
echo ""

# 3. Detect project type and run appropriate checks
echo -e "${BLUE}[3/5] Detecting project type...${NC}"

# Check for Node.js/TypeScript
if [ -f "package.json" ]; then
    echo -e "${YELLOW}→ Node.js project detected${NC}"
    
    # Check if npm is available before running npm commands
    if ! command -v npm &> /dev/null; then
        echo -e "${YELLOW}  SKIP: npm not installed (lint/typecheck/test skipped)${NC}"
    else
        # Check for lint script
        if grep -q '"lint"' "package.json" 2>/dev/null; then
            echo -e "${BLUE}  Running lint...${NC}"
            if npm run -s lint >/dev/null 2>&1; then
                echo -e "${GREEN}  ✓ Lint passed${NC}"
            else
                echo -e "${RED}  ✗ Lint failed${NC}"
                npm run lint 2>&1 | head -20 || true
                ERRORS=$((ERRORS + 1))
            fi
        else
            echo -e "${YELLOW}  SKIP: No 'lint' script in package.json${NC}"
        fi
        
        # Check for typecheck script
        if grep -q '"typecheck"' "package.json" 2>/dev/null || grep -q '"type-check"' "package.json" 2>/dev/null; then
            echo -e "${BLUE}  Running typecheck...${NC}"
            if grep -q '"typecheck"' "package.json" 2>/dev/null; then
                if npm run -s typecheck >/dev/null 2>&1; then
                    echo -e "${GREEN}  ✓ Typecheck passed${NC}"
                else
                    echo -e "${RED}  ✗ Typecheck failed${NC}"
                    npm run typecheck 2>&1 | head -20 || true
                    ERRORS=$((ERRORS + 1))
                fi
            elif grep -q '"type-check"' "package.json" 2>/dev/null; then
                if npm run -s type-check >/dev/null 2>&1; then
                    echo -e "${GREEN}  ✓ Typecheck passed${NC}"
                else
                    echo -e "${RED}  ✗ Typecheck failed${NC}"
                    npm run type-check 2>&1 | head -20 || true
                    ERRORS=$((ERRORS + 1))
                fi
            fi
        else
            echo -e "${YELLOW}  SKIP: No 'typecheck' or 'type-check' script in package.json${NC}"
        fi
        
        # Check for test script
        if grep -q '"test"' "package.json" 2>/dev/null; then
            echo -e "${BLUE}  Running tests...${NC}"
            if npm run -s test >/dev/null 2>&1; then
                echo -e "${GREEN}  ✓ Tests passed${NC}"
            else
                echo -e "${RED}  ✗ Tests failed${NC}"
                npm test 2>&1 | head -20 || true
                ERRORS=$((ERRORS + 1))
            fi
        else
            echo -e "${YELLOW}  SKIP: No 'test' script in package.json${NC}"
        fi
    fi
fi

# Check for Python
if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
    echo -e "${YELLOW}→ Python project detected${NC}"
    
    # Check for pytest
    if command -v pytest &> /dev/null; then
        echo -e "${BLUE}  Running pytest...${NC}"
        if pytest 2>/dev/null; then
            echo -e "${GREEN}  ✓ Tests passed${NC}"
        else
            echo -e "${RED}  ✗ Tests failed${NC}"
            ERRORS=$((ERRORS + 1))
        fi
    else
        echo -e "${YELLOW}  SKIP: pytest not installed${NC}"
    fi
    
    # Check for mypy
    if command -v mypy &> /dev/null; then
        echo -e "${BLUE}  Running mypy...${NC}"
        if mypy . 2>/dev/null; then
            echo -e "${GREEN}  ✓ Typecheck passed${NC}"
        else
            echo -e "${YELLOW}  ⚠ Typecheck warnings (non-blocking)${NC}"
            WARNINGS=$((WARNINGS + 1))
        fi
    else
        echo -e "${YELLOW}  SKIP: mypy not installed${NC}"
    fi
fi

# Check for Rust
if [ -f "Cargo.toml" ]; then
    echo -e "${YELLOW}→ Rust project detected${NC}"
    
    # Check for cargo clippy
    if command -v cargo &> /dev/null; then
        CARGO_OUTPUT=$(mktemp) || exit 1
        
        echo -e "${BLUE}  Running cargo clippy...${NC}"
        if cargo clippy -- -D warnings > "$CARGO_OUTPUT" 2>&1; then
            echo -e "${GREEN}  ✓ Clippy passed${NC}"
        else
            echo -e "${RED}  ✗ Clippy failed${NC}"
            echo -e "${RED}  Last 20 lines of output:${NC}"
            tail -20 "$CARGO_OUTPUT" || true
            ERRORS=$((ERRORS + 1))
        fi
        
        echo -e "${BLUE}  Running cargo test...${NC}"
        if cargo test > "$CARGO_OUTPUT" 2>&1; then
            echo -e "${GREEN}  ✓ Tests passed${NC}"
        else
            echo -e "${RED}  ✗ Tests failed${NC}"
            echo -e "${RED}  Last 20 lines of output:${NC}"
            tail -20 "$CARGO_OUTPUT" || true
            ERRORS=$((ERRORS + 1))
        fi
        
        rm -f "$CARGO_OUTPUT"
    else
        echo -e "${YELLOW}  SKIP: cargo not installed${NC}"
    fi
fi

# Check if no project type was detected
if [ ! -f "package.json" ] && [ ! -f "requirements.txt" ] && [ ! -f "pyproject.toml" ] && [ ! -f "setup.py" ] && [ ! -f "Cargo.toml" ]; then
    echo -e "${YELLOW}→ No known project type detected (skipping lint/tests).${NC}"
fi

echo ""

# 4. Check git status
echo -e "${BLUE}[4/5] Checking git status...${NC}"
if [ -d ".git" ] && command -v git &> /dev/null; then
    GIT_STATUS=$(git status --porcelain 2>/dev/null || echo "")
    if [ -n "$GIT_STATUS" ]; then
        echo -e "${YELLOW}⚠ Uncommitted changes detected${NC}"
        WARNINGS=$((WARNINGS + 1))
    else
        echo -e "${GREEN}✓ Working directory clean${NC}"
    fi
else
    if [ ! -d ".git" ]; then
        echo -e "${YELLOW}⚠ Not a git repository${NC}"
    fi
fi
echo ""

# 5. Optional: Validate PLAN.md (if --plan flag provided)
if [ "$CHECK_PLAN" -eq 1 ] && [ "$IS_TEMPLATE_MODE" -eq 0 ]; then
    echo -e "${BLUE}[5/6] Validating PLAN.md (optional)...${NC}"
    VALIDATE_PLAN_SCRIPT="$SCRIPT_DIR/validate-plan.sh"
    if [ -f "$VALIDATE_PLAN_SCRIPT" ]; then
        if bash "$VALIDATE_PLAN_SCRIPT" 2>/dev/null; then
            echo -e "${GREEN}✓ PLAN.md validation passed${NC}"
        else
            PLAN_EXIT_CODE=$?
            if [ "$PLAN_EXIT_CODE" -eq 1 ]; then
                echo -e "${YELLOW}⚠ PLAN.md validation failed or missing${NC}"
                echo -e "${YELLOW}  Action: Create/update PLAN.md in .cursor/work/ before implementation${NC}"
                WARNINGS=$((WARNINGS + 1))
            fi
        fi
    else
        echo -e "${YELLOW}SKIP: validate-plan.sh not found${NC}"
    fi
    echo ""
fi

# 6. Optional: Validate REVIEW.md (if --review flag provided)
if [ "$CHECK_REVIEW" -eq 1 ] && [ "$IS_TEMPLATE_MODE" -eq 0 ]; then
    echo -e "${BLUE}[6/6] Validating REVIEW.md (optional)...${NC}"
    REVIEW_CHECK_SCRIPT="$SCRIPT_DIR/review-check.sh"
    if [ -f "$REVIEW_CHECK_SCRIPT" ]; then
        if bash "$REVIEW_CHECK_SCRIPT" 2>/dev/null; then
            echo -e "${GREEN}✓ REVIEW.md validation passed${NC}"
        else
            REVIEW_EXIT_CODE=$?
            if [ "$REVIEW_EXIT_CODE" -eq 1 ]; then
                echo -e "${YELLOW}⚠ REVIEW.md validation failed or missing${NC}"
                echo -e "${YELLOW}  Action: Create/update REVIEW.md in .cursor/work/ with Verdict${NC}"
                WARNINGS=$((WARNINGS + 1))
            fi
        fi
    else
        echo -e "${YELLOW}SKIP: review-check.sh not found${NC}"
    fi
    echo ""
fi

# Summary and next actions
STEP_COUNT=5
if [ "$CHECK_PLAN" -eq 1 ] || [ "$CHECK_REVIEW" -eq 1 ]; then
    STEP_COUNT=6
fi
echo -e "${BLUE}[${STEP_COUNT}/${STEP_COUNT}] Summary${NC}"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    echo -e "${GREEN}OK${NC}"
    echo ""
    echo -e "${BLUE}Next actions:${NC}"
    echo "  1. Review code changes"
    echo "  2. Update documentation if needed"
    echo "  3. Create PR following 5-open-source-pr.mdc"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}✓ Checks passed with ${WARNINGS} warning(s)${NC}"
    echo -e "${GREEN}OK${NC}"
    echo ""
    echo -e "${BLUE}Next actions:${NC}"
    echo "  1. Address warnings above"
    echo "  2. Review code changes"
    echo "  3. Create PR following 5-open-source-pr.mdc"
    exit 0
else
    echo -e "${RED}✗ Checks failed: ${ERRORS} error(s), ${WARNINGS} warning(s)${NC}"
    echo ""
    echo -e "${BLUE}Next actions:${NC}"
    echo "  1. Fix errors listed above"
    echo "  2. Run this script again to verify"
    echo "  3. Address warnings if any"
    exit 1
fi
