#!/bin/bash

# Validate Cursor rules structure and frontmatter
# Ensures all .mdc files have proper frontmatter and no duplicate filenames
# Works from: <project>/.cursor/scripts/ or template/scripts/
# Resolves rules directory relative to script location only (no pwd guessing)

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Resolve rules directory relative to script location
# Case A: target project: <project>/.cursor/scripts/validate-rules.sh
#         → rules dir is <project>/.cursor/rules (parent of scripts/)
# Case B: template repo: template/scripts/validate-rules.sh
#         → rules dir is template/.cursor/rules (sibling of scripts/)
if [ "$(basename "$(dirname "$SCRIPT_DIR")")" = ".cursor" ]; then
    # Case A: Running from target project
    CURSOR_DIR="$(dirname "$SCRIPT_DIR")"
    RULES_DIR="$CURSOR_DIR/rules"
else
    # Case B: Running from template
    TEMPLATE_DIR="$(dirname "$SCRIPT_DIR")"
    RULES_DIR="$TEMPLATE_DIR/.cursor/rules"
fi

ERRORS=0
WARNINGS=0

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "Validating Cursor rules in ${RULES_DIR}..."

# Check if rules directory exists
if [ ! -d "$RULES_DIR" ]; then
    echo -e "${RED}Error: Rules directory not found${NC}"
    echo -e "${RED}  Expected: ${RULES_DIR}${NC}"
    echo -e "${RED}  Script location: ${SCRIPT_DIR}${NC}"
    if [ "$(basename "$(dirname "$SCRIPT_DIR")")" = ".cursor" ]; then
        echo -e "${RED}  This script should be in <project>/.cursor/scripts/${NC}"
        echo -e "${RED}  Action: Ensure .cursor/rules/ exists in your project${NC}"
    else
        echo -e "${RED}  This script should be in template/scripts/${NC}"
        echo -e "${RED}  Action: Ensure template/.cursor/rules/ exists${NC}"
    fi
    exit 1
fi

# Find all .mdc files using null-delimited output for robustness
MDC_COUNT=0
while IFS= read -r -d '' file; do
    MDC_COUNT=$((MDC_COUNT + 1))
done < <(find "$RULES_DIR" -name "*.mdc" -type f -print0 2>/dev/null || true)

if [ "$MDC_COUNT" -eq 0 ]; then
    echo -e "${YELLOW}Warning: No .mdc files found in ${RULES_DIR}${NC}"
    exit 0
fi

# Check for duplicate filenames (Bash 3 compatible: use sort/uniq)
echo "Checking for duplicate filenames..."
# Build a list of "basename|fullpath" entries, sort by basename, find duplicates
TEMP_LIST=$(mktemp) || exit 1
DUP_BASENAMES_FILE=$(mktemp) || exit 1

trap 'rm -f "${TEMP_LIST:-}" "${DUP_BASENAMES_FILE:-}"' EXIT

# Create list of basename|fullpath
while IFS= read -r -d '' file; do
    filename=$(basename "$file")
    echo "${filename}|${file}" >> "$TEMP_LIST"
done < <(find "$RULES_DIR" -name "*.mdc" -type f -print0 2>/dev/null || true)

# Find duplicates using direct pipeline (avoid storing large lists in variables)
cut -d'|' -f1 "$TEMP_LIST" | sort | uniq -d > "$DUP_BASENAMES_FILE" || true

if [ -s "$DUP_BASENAMES_FILE" ]; then
    echo -e "${RED}Error: Duplicate filenames found:${NC}"
    ERRORS=$((ERRORS + 1))
    
    # Process each duplicate basename
    while IFS= read -r dup_basename; do
        [ -z "$dup_basename" ] && continue
        echo -e "${RED}  ${dup_basename}${NC}"
        
        # Use awk to match first field exactly (safe for special characters)
        # Count total matches and print first 2 in a single pass
        TOTAL_MATCHES=$(awk -F'|' -v name="$dup_basename" '$1 == name {count++} END {print count+0}' "$TEMP_LIST")
        
        # Print exactly 2 paths minimum (no temp file, use awk to print directly)
        awk -F'|' -v name="$dup_basename" -v red="$RED" -v nc="$NC" '
            $1 == name {
                if (count < 2) {
                    printf "%s    → %s%s\n", red, $2, nc
                    count++
                }
            }
        ' "$TEMP_LIST"
        
        # If more than 2 files, show count
        if [ "$TOTAL_MATCHES" -gt 2 ]; then
            echo -e "${RED}    ... and $((TOTAL_MATCHES - 2)) more occurrence(s)${NC}"
        fi
    done < "$DUP_BASENAMES_FILE"
fi

# Validate each .mdc file
echo "Validating frontmatter in .mdc files..."
while IFS= read -r -d '' file; do
    filename=$(basename "$file")
    
    # Check that file starts with --- on line 1
    FIRST_LINE=$(head -n 1 "$file" 2>/dev/null || echo "")
    if [ "$FIRST_LINE" != "---" ]; then
        echo -e "${RED}Error: ${filename} missing frontmatter (file must start with --- on line 1)${NC}"
        echo -e "${RED}  Action: Add frontmatter block starting with --- at the beginning of the file${NC}"
        ERRORS=$((ERRORS + 1))
        continue
    fi
    
    # Find the second --- delimiter (closing frontmatter)
    # Count occurrences of --- on separate lines, find line number of second occurrence
    SECOND_DELIMITER_LINE=$(awk '/^---$/{if(++count==2){print NR; exit}}' "$file" 2>/dev/null || echo "")
    
    if [ -z "$SECOND_DELIMITER_LINE" ]; then
        echo -e "${RED}Error: ${filename} has incomplete frontmatter (missing closing --- delimiter)${NC}"
        echo -e "${RED}  Action: Ensure frontmatter is properly closed with --- on a separate line${NC}"
        ERRORS=$((ERRORS + 1))
        continue
    fi
    
    # Check if there are additional --- delimiters after the closing one (warning only)
    # Ignore --- that appear inside fenced code blocks (``` or ~~~)
    # Use awk to track code block state and count only --- outside code blocks
    TOTAL_DELIMITERS=$(awk '
        BEGIN { in_code_block = 0; code_block_marker = ""; count = 0 }
        # Detect fenced code block start/end (``` or ~~~)
        /^```/ || /^~~~/ {
            if (in_code_block == 0) {
                # Starting a code block
                in_code_block = 1
                code_block_marker = substr($0, 1, 3)
            } else if (substr($0, 1, 3) == code_block_marker) {
                # Ending the code block (same marker)
                in_code_block = 0
                code_block_marker = ""
            }
            next
        }
        # Count --- only if not inside a code block
        /^---$/ {
            if (in_code_block == 0) {
                count++
            }
        }
        END { print count }
    ' "$file" 2>/dev/null || echo "0")
    
    if [ "$TOTAL_DELIMITERS" -gt 2 ]; then
        echo -e "${YELLOW}Warning: ${filename} has additional --- delimiter(s) after frontmatter (found ${TOTAL_DELIMITERS} total)${NC}"
        echo -e "${YELLOW}  This may indicate formatting issues, but is not an error${NC}"
        WARNINGS=$((WARNINGS + 1))
    fi
    
    # Extract frontmatter (between first two ---)
    FRONTMATTER=$(awk '/^---$/{if(++count==1)next; if(count==2)exit} count' "$file" 2>/dev/null || echo "")
    
    if [ -z "$FRONTMATTER" ]; then
        echo -e "${RED}Error: ${filename} frontmatter extraction failed${NC}"
        echo -e "${RED}  Action: Check file format and ensure frontmatter is valid YAML${NC}"
        ERRORS=$((ERRORS + 1))
        continue
    fi
    
    # Check for required fields (tolerate leading whitespace and spaces before colon)
    if ! echo "$FRONTMATTER" | grep -qE "^[[:space:]]*description[[:space:]]*:"; then
        echo -e "${RED}Error: ${filename} missing required 'description' field in frontmatter${NC}"
        echo -e "${RED}  Action: Add 'description: <your description>' to the frontmatter${NC}"
        ERRORS=$((ERRORS + 1))
    fi
    
    # Check for either globs or alwaysApply (tolerate leading whitespace and spaces before colon)
    HAS_GLOBS=$(echo "$FRONTMATTER" | grep -qE "^[[:space:]]*globs[[:space:]]*:" && echo "yes" || echo "no")
    HAS_ALWAYS_APPLY=$(echo "$FRONTMATTER" | grep -qE "^[[:space:]]*alwaysApply[[:space:]]*:" && echo "yes" || echo "no")
    
    if [ "$HAS_GLOBS" = "no" ] && [ "$HAS_ALWAYS_APPLY" = "no" ]; then
        echo -e "${RED}Error: ${filename} missing both 'globs' and 'alwaysApply' fields${NC}"
        echo -e "${RED}  Action: Add either 'globs: [\"pattern\"]' or 'alwaysApply: true' to frontmatter${NC}"
        ERRORS=$((ERRORS + 1))
    fi
    
    # Check for deprecated field (warning only, tolerate leading whitespace and spaces)
    if echo "$FRONTMATTER" | grep -qE "^[[:space:]]*deprecated[[:space:]]*:[[:space:]]*true"; then
        REPLACED_BY=$(echo "$FRONTMATTER" | grep -E "^[[:space:]]*replacedBy[[:space:]]*:" | sed 's/.*replacedBy[[:space:]]*:[[:space:]]*//' | tr -d '"' | tr -d "'" || echo "")
        if [ -n "$REPLACED_BY" ]; then
            echo -e "${YELLOW}Warning: ${filename} is deprecated, replaced by ${REPLACED_BY}${NC}"
            WARNINGS=$((WARNINGS + 1))
        else
            echo -e "${YELLOW}Warning: ${filename} is deprecated but no replacement specified${NC}"
            WARNINGS=$((WARNINGS + 1))
        fi
    fi
done < <(find "$RULES_DIR" -name "*.mdc" -type f -print0 2>/dev/null || true)

# Summary
echo ""
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ Validation passed: All rules are valid${NC}"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}✓ Validation passed with ${WARNINGS} warning(s)${NC}"
    exit 0
else
    echo -e "${RED}✗ Validation failed: ${ERRORS} error(s), ${WARNINGS} warning(s)${NC}"
    echo -e "${RED}  Action: Fix the errors above and rerun validation${NC}"
    exit 1
fi
