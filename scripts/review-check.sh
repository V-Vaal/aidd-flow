#!/bin/bash

# Validate REVIEW.md structure and suggest domain-specific checklists
# Ensures REVIEW.md exists, Verdict is present and valid, and suggests appropriate checklists
# Works from: <project>/.cursor/scripts/ or scripts/ at repository root
# Resolves directories relative to script location only (no pwd guessing)

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Resolve directories relative to script location
# Case A: target project: <project>/.cursor/scripts/review-check.sh
#         → work dir is <project>/.cursor/work, memory dir is <project>/.cursor/memory
# Case B: repository root: scripts/review-check.sh
#         → work dir is .cursor/work, memory dir is .cursor/memory
if [ "$(basename "$(dirname "$SCRIPT_DIR")")" = ".cursor" ]; then
    # Case A: Running from target project
    CURSOR_DIR="$(dirname "$SCRIPT_DIR")"
    WORK_DIR="$CURSOR_DIR/work"
    MEMORY_DIR="$CURSOR_DIR/memory"
    REVIEW_DIR="$CURSOR_DIR/review"
else
    # Case B: Running from repository root
    REPO_ROOT="$(dirname "$SCRIPT_DIR")"
    WORK_DIR="$REPO_ROOT/.cursor/work"
    MEMORY_DIR="$REPO_ROOT/.cursor/memory"
    REVIEW_DIR="$REPO_ROOT/.cursor/review"
fi

REVIEW_FILE="$WORK_DIR/REVIEW.md"
TECH_CONTEXT="$MEMORY_DIR/techContext.md"

ERRORS=0
WARNINGS=0

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "Validating REVIEW.md..."

# Check if REVIEW.md exists
if [ ! -f "$REVIEW_FILE" ]; then
    echo -e "${RED}Error: REVIEW.md not found${NC}"
    echo -e "${RED}  Expected: ${REVIEW_FILE}${NC}"
    echo -e "${RED}  Action: Create REVIEW.md in .cursor/work/ before proceeding${NC}"
    exit 1
fi

# Extract Verdict section
VERDICT_SECTION=$(grep -A 5 "^## Verdict" "$REVIEW_FILE" || echo "")
VERDICT_LINE=$(echo "$VERDICT_SECTION" | grep -iE "^\*\*Verdict\*\*|^Verdict" | head -1 || echo "")

# Check if Verdict exists
if [ -z "$VERDICT_LINE" ]; then
    echo -e "${RED}Error: Verdict field is missing${NC}"
    echo -e "${RED}  Action: Add '**Verdict**: [APPROVE | CHANGES_REQUESTED]' to REVIEW.md${NC}"
    ERRORS=$((ERRORS + 1))
else
    # Extract verdict value
    VERDICT_VALUE=$(echo "$VERDICT_LINE" | sed -E 's/.*[Vv]erdict[:\*]*[[:space:]]*//' | tr -d '[]' | tr '[:lower:]' '[:upper:]' | xargs)
    
    # Check if verdict is valid
    if [ "$VERDICT_VALUE" != "APPROVE" ] && [ "$VERDICT_VALUE" != "CHANGES_REQUESTED" ]; then
        echo -e "${RED}Error: Invalid Verdict value: ${VERDICT_VALUE}${NC}"
        echo -e "${RED}  Action: Verdict must be either APPROVE or CHANGES_REQUESTED${NC}"
        ERRORS=$((ERRORS + 1))
    else
        echo -e "${GREEN}✓ Verdict: ${VERDICT_VALUE}${NC}"
    fi
fi

# Check Test evidence section
TEST_EVIDENCE_SECTION=$(grep -A 10 "^## Test evidence" "$REVIEW_FILE" || echo "")
# Remove the heading line and check if there's actual content
TEST_CONTENT=$(echo "$TEST_EVIDENCE_SECTION" | tail -n +2 | grep -vE '^[[:space:]]*$' | grep -vE '^[[:space:]]*-[[:space:]]*\[[[:space:]]*\][[:space:]]*$' || echo "")

if [ -z "$TEST_CONTENT" ]; then
    echo -e "${YELLOW}Warning: Test evidence section appears to be empty${NC}"
    echo -e "${YELLOW}  Action: Add test evidence to REVIEW.md${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

# Determine domain from techContext.md
DOMAIN=""
if [ -f "$TECH_CONTEXT" ]; then
    # Extract Domain from metadata section
    DOMAIN_LINE=$(grep -iE "^\*\*Domain\*\*|^Domain" "$TECH_CONTEXT" | head -1 || echo "")
    if [ -n "$DOMAIN_LINE" ]; then
        DOMAIN=$(echo "$DOMAIN_LINE" | sed -E 's/.*[Dd]omain[:\*]*[[:space:]]*//' | sed -E 's/\[.*\]//' | tr '[:upper:]' '[:lower:]' | xargs)
    fi
fi

# Fallback heuristic: check for common indicators
if [ -z "$DOMAIN" ] || [ "$DOMAIN" = "other" ]; then
    echo -e "${YELLOW}Warning: Domain metadata not found or set to 'other'${NC}"
    echo -e "${YELLOW}  Attempting heuristic detection...${NC}"
    
    # Check for Web3 indicators
    if [ -f "$TECH_CONTEXT" ]; then
        if grep -qiE "solidity|ethereum|web3|blockchain|smart.?contract|hardhat|foundry|viem|wagmi" "$TECH_CONTEXT"; then
            DOMAIN="web3"
            echo -e "${YELLOW}  Detected Web3 indicators in techContext.md${NC}"
        elif grep -qiE "tensorflow|pytorch|keras|scikit|machine.?learning|ml|neural|model|training|dataset" "$TECH_CONTEXT"; then
            DOMAIN="ml"
            echo -e "${YELLOW}  Detected ML indicators in techContext.md${NC}"
        fi
    fi
fi

# Suggest checklists based on domain
echo ""
echo -e "${BLUE}=== Domain-Specific Checklists ===${NC}"

if [ "$DOMAIN" = "web3" ]; then
    CHECKLIST_FILE="$REVIEW_DIR/review-checklist-web3.md"
    if [ -f "$CHECKLIST_FILE" ]; then
        echo -e "${GREEN}✓ Web3 checklist available: ${CHECKLIST_FILE}${NC}"
        echo -e "  Review the checklist and ensure all relevant items are addressed."
    else
        echo -e "${YELLOW}⚠ Web3 checklist not found at ${CHECKLIST_FILE}${NC}"
    fi
elif [ "$DOMAIN" = "ml" ]; then
    CHECKLIST_FILE="$REVIEW_DIR/review-checklist-ml.md"
    if [ -f "$CHECKLIST_FILE" ]; then
        echo -e "${GREEN}✓ ML checklist available: ${CHECKLIST_FILE}${NC}"
        echo -e "  Review the checklist and ensure all relevant items are addressed."
    else
        echo -e "${YELLOW}⚠ ML checklist not found at ${CHECKLIST_FILE}${NC}"
    fi
elif [ "$DOMAIN" = "mixed" ]; then
    WEB3_CHECKLIST="$REVIEW_DIR/review-checklist-web3.md"
    ML_CHECKLIST="$REVIEW_DIR/review-checklist-ml.md"
    echo -e "${GREEN}✓ Mixed domain detected - both checklists recommended:${NC}"
    if [ -f "$WEB3_CHECKLIST" ]; then
        echo -e "  - Web3: ${WEB3_CHECKLIST}"
    fi
    if [ -f "$ML_CHECKLIST" ]; then
        echo -e "  - ML: ${ML_CHECKLIST}"
    fi
    echo -e "  Review both checklists and ensure all relevant items are addressed."
else
    echo -e "${YELLOW}⚠ No domain-specific checklist applies${NC}"
    echo -e "  Domain: ${DOMAIN:-not detected}"
    echo -e "  Update techContext.md with Domain metadata (web3 | ml | mixed | other) to enable checklist suggestions."
fi

# Summary
echo ""
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ REVIEW.md validation passed${NC}"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}✓ REVIEW.md validation passed with ${WARNINGS} warning(s)${NC}"
    exit 0
else
    echo -e "${RED}✗ REVIEW.md validation failed: ${ERRORS} error(s), ${WARNINGS} warning(s)${NC}"
    echo -e "${RED}  Action: Fix the errors above and rerun validation${NC}"
    exit 1
fi

