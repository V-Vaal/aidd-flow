#!/bin/bash

# Validate PLAN.md structure
# Ensures PLAN.md exists and contains all required sections
# Works from: <project>/.cursor/scripts/ or scripts/ at repository root
# Resolves work directory relative to script location only (no pwd guessing)

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Resolve work directory relative to script location
# Case A: target project: <project>/.cursor/scripts/validate-plan.sh
#         → work dir is <project>/.cursor/work (parent of scripts/, sibling of rules/)
# Case B: repository root: scripts/validate-plan.sh
#         → work dir is .cursor/work (sibling of scripts/)
if [ "$(basename "$(dirname "$SCRIPT_DIR")")" = ".cursor" ]; then
    # Case A: Running from target project
    CURSOR_DIR="$(dirname "$SCRIPT_DIR")"
    WORK_DIR="$CURSOR_DIR/work"
else
    # Case B: Running from repository root
    REPO_ROOT="$(dirname "$SCRIPT_DIR")"
    WORK_DIR="$REPO_ROOT/.cursor/work"
fi

PLAN_FILE="$WORK_DIR/PLAN.md"

ERRORS=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "Validating PLAN.md..."

# Check if PLAN.md exists
if [ ! -f "$PLAN_FILE" ]; then
    echo -e "${RED}Error: PLAN.md not found${NC}"
    echo -e "${RED}  Expected: ${PLAN_FILE}${NC}"
    echo -e "${RED}  Action: Create PLAN.md in .cursor/work/ before proceeding${NC}"
    exit 1
fi

# Extract all markdown headings (## and ###)
# We'll check for required sections by matching heading text
HEADINGS=$(grep -E '^##+ ' "$PLAN_FILE" | sed 's/^##* //' || echo "")

# Required sections (case-insensitive matching)
# Tolerated variations documented in comments
REQUIRED_SECTIONS=(
    "Goal"
    "Scope"
    "Out-of-scope"
    "Files to touch"
    "Steps"
    "Tests / Checks|Tests"  # Accepts "Tests / Checks" or "Tests"
    "Rollback|Rollback plan"  # Accepts "Rollback" or "Rollback plan"
)

# Function to check if a section exists (handles variations)
check_section() {
    local pattern="$1"
    local found=0
    
    # Check if any heading matches the pattern (case-insensitive)
    while IFS= read -r heading; do
        if echo "$heading" | grep -qiE "^($pattern)$"; then
            found=1
            break
        fi
    done <<< "$HEADINGS"
    
    if [ "$found" -eq 0 ]; then
        echo -e "${RED}Error: Missing required section: ${pattern}${NC}"
        echo -e "${RED}  Action: Add a '## ${pattern}' section to PLAN.md${NC}"
        ERRORS=$((ERRORS + 1))
        return 1
    fi
    return 0
}

# Check each required section
for section_pattern in "${REQUIRED_SECTIONS[@]}"; do
    check_section "$section_pattern"
done

# Summary
echo ""
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ PLAN.md validation passed: All required sections present${NC}"
    exit 0
else
    echo -e "${RED}✗ PLAN.md validation failed: ${ERRORS} missing section(s)${NC}"
    echo -e "${RED}  Action: Add the missing sections above and rerun validation${NC}"
    exit 1
fi

