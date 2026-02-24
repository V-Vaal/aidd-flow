#!/bin/bash

# Validate rules structure
# Ensures all .md files in rules/ have a top-level heading and no duplicate filenames
# Run from repository root: bash scripts/validate-rules.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
RULES_DIR="$REPO_ROOT/rules"

ERRORS=0
WARNINGS=0

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

echo "Validating rules in ${RULES_DIR}..."

if [ ! -d "$RULES_DIR" ]; then
    echo -e "${RED}Error: Rules directory not found${NC}"
    echo -e "${RED}  Expected: ${RULES_DIR}${NC}"
    echo -e "${RED}  Action: Ensure rules/ exists in repository root${NC}"
    exit 1
fi

MD_COUNT=0
while IFS= read -r -d '' file; do
    # Skip .gitkeep and INDEX.md
    filename=$(basename "$file")
    [[ "$filename" == ".gitkeep" || "$filename" == "INDEX.md" ]] && continue
    MD_COUNT=$((MD_COUNT + 1))
done < <(find "$RULES_DIR" -name "*.md" -type f -print0 2>/dev/null || true)

if [ "$MD_COUNT" -eq 0 ]; then
    echo -e "${YELLOW}Warning: No rule .md files found in ${RULES_DIR}${NC}"
    exit 0
fi

echo "Found ${MD_COUNT} rule file(s). Checking for duplicate filenames..."

# Check for duplicate filenames
TEMP_LIST=$(mktemp) || exit 1
DUP_BASENAMES_FILE=$(mktemp) || exit 1
trap 'rm -f "${TEMP_LIST:-}" "${DUP_BASENAMES_FILE:-}"' EXIT

while IFS= read -r -d '' file; do
    filename=$(basename "$file")
    [[ "$filename" == ".gitkeep" || "$filename" == "INDEX.md" ]] && continue
    echo "${filename}|${file}" >> "$TEMP_LIST"
done < <(find "$RULES_DIR" -name "*.md" -type f -print0 2>/dev/null || true)

cut -d'|' -f1 "$TEMP_LIST" | sort | uniq -d > "$DUP_BASENAMES_FILE" || true

if [ -s "$DUP_BASENAMES_FILE" ]; then
    echo -e "${RED}Error: Duplicate filenames found:${NC}"
    ERRORS=$((ERRORS + 1))
    while IFS= read -r dup_basename; do
        [ -z "$dup_basename" ] && continue
        echo -e "${RED}  ${dup_basename}${NC}"
        awk -F'|' -v name="$dup_basename" -v red="$RED" -v nc="$NC" \
            '$1 == name { if (count < 2) { printf "%s    → %s%s\n", red, $2, nc; count++ } }' "$TEMP_LIST"
    done < "$DUP_BASENAMES_FILE"
fi

# Validate each rule file: must have a top-level heading (# Title)
echo "Validating rule file structure..."
while IFS= read -r -d '' file; do
    filename=$(basename "$file")
    [[ "$filename" == ".gitkeep" || "$filename" == "INDEX.md" ]] && continue

    # Must not start with YAML frontmatter
    FIRST_LINE=$(head -n 1 "$file" 2>/dev/null || echo "")
    if [ "$FIRST_LINE" = "---" ]; then
        echo -e "${RED}Error: ${filename} still contains YAML frontmatter (starts with ---)${NC}"
        echo -e "${RED}  Action: Remove the frontmatter block — rules are plain Markdown${NC}"
        ERRORS=$((ERRORS + 1))
        continue
    fi

    # Must have at least one heading
    HAS_HEADING=$(grep -c "^#" "$file" 2>/dev/null || echo "0")
    if [ "$HAS_HEADING" -eq 0 ]; then
        echo -e "${YELLOW}Warning: ${filename} has no Markdown heading${NC}"
        echo -e "${YELLOW}  Suggestion: Add a # Title at the top of the file${NC}"
        WARNINGS=$((WARNINGS + 1))
    fi

    # Must not be empty
    LINE_COUNT=$(wc -l < "$file" 2>/dev/null || echo "0")
    if [ "$LINE_COUNT" -lt 3 ]; then
        echo -e "${YELLOW}Warning: ${filename} appears to be empty or near-empty (${LINE_COUNT} lines)${NC}"
        WARNINGS=$((WARNINGS + 1))
    fi
done < <(find "$RULES_DIR" -name "*.md" -type f -print0 2>/dev/null || true)

echo ""
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ Validation passed: All ${MD_COUNT} rule files are valid${NC}"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}✓ Validation passed with ${WARNINGS} warning(s) across ${MD_COUNT} files${NC}"
    exit 0
else
    echo -e "${RED}✗ Validation failed: ${ERRORS} error(s), ${WARNINGS} warning(s)${NC}"
    echo -e "${RED}  Action: Fix the errors above and rerun validation${NC}"
    exit 1
fi
