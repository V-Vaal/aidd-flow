#!/bin/bash

# Validate INTAKE.md structure
# Ensures INTAKE.md exists and contains all required sections
# Works from: <project>/.cursor/scripts/ or template/scripts/
# Resolves work directory relative to script location only (no pwd guessing)

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Resolve work directory relative to script location
# Case A: target project: <project>/.cursor/scripts/validate-intake.sh
#         → work dir is <project>/.cursor/work (parent of scripts/, sibling of rules/)
# Case B: template repo: template/scripts/validate-intake.sh
#         → work dir is template/.cursor/work (sibling of scripts/)
if [ "$(basename "$(dirname "$SCRIPT_DIR")")" = ".cursor" ]; then
    # Case A: Running from target project
    CURSOR_DIR="$(dirname "$SCRIPT_DIR")"
    WORK_DIR="$CURSOR_DIR/work"
else
    # Case B: Running from template
    TEMPLATE_DIR="$(dirname "$SCRIPT_DIR")"
    WORK_DIR="$TEMPLATE_DIR/.cursor/work"
fi

INTAKE_FILE="$WORK_DIR/INTAKE.md"

ERRORS=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "Validating INTAKE.md..."

# Check if INTAKE.md exists
if [ ! -f "$INTAKE_FILE" ]; then
    echo -e "${RED}Error: INTAKE.md not found${NC}"
    echo -e "${RED}  Expected: ${INTAKE_FILE}${NC}"
    echo -e "${RED}  Action: Create INTAKE.md in .cursor/work/ before proceeding${NC}"
    exit 1
fi

# Read file content for section and field checks
FILE_CONTENT=$(cat "$INTAKE_FILE" || echo "")

# Check for Artefact Status
if ! echo "$FILE_CONTENT" | grep -qiE "^\*\*Artefact Status\*\*.*(DRAFT|REVIEWED|APPROVED)"; then
    echo -e "${RED}Error: Missing or empty 'Artefact Status' field${NC}"
    echo -e "${RED}  Action: Add '**Artefact Status**: DRAFT | REVIEWED | APPROVED' at the top${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Check for Change Class
if ! echo "$FILE_CONTENT" | grep -qiE "^\*\*Change Class\*\*.*(A|B|C)"; then
    echo -e "${RED}Error: Missing or empty 'Change Class' field${NC}"
    echo -e "${RED}  Action: Add '**Change Class**: A | B | C' with guidance${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Extract all markdown headings (## and ###)
HEADINGS=$(grep -E '^##+ ' "$INTAKE_FILE" | sed 's/^##* //' || echo "")

# Required sections (case-insensitive matching)
REQUIRED_SECTIONS=(
    "Goal"
    "Scope"
    "Definition of Done|Definition of done"
    "Risks"
    "Evidence Requirements|Evidence requirements"
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
        echo -e "${RED}  Action: Add a '## ${pattern}' section to INTAKE.md${NC}"
        ERRORS=$((ERRORS + 1))
        return 1
    fi
    return 0
}

# Check each required section
for section_pattern in "${REQUIRED_SECTIONS[@]}"; do
    check_section "$section_pattern"
done

# Check for non-empty sections (must have content beyond template placeholders)
check_section_content() {
    local section_name="$1"
    local section_content=""
    local in_section=0
    local start_line=0
    local end_line=0
    local line_num=0
    
    # Find the section start line (case-insensitive, handles ## or ###)
    while IFS= read -r line; do
        line_num=$((line_num + 1))
        # Check if this is the section heading (case-insensitive, allows ## or ###)
        if echo "$line" | grep -qiE "^##+[[:space:]]+${section_name}[[:space:]]*$"; then
            start_line=$line_num
            in_section=1
            continue
        fi
        
        # If we're in the section and hit another top-level heading (##), stop
        if [ "$in_section" -eq 1 ] && echo "$line" | grep -qE '^##[[:space:]]+'; then
            end_line=$((line_num - 1))
            break
        fi
    done < "$INTAKE_FILE"
    
    # If section was found but no end_line set, section goes to end of file
    if [ "$in_section" -eq 1 ] && [ "$end_line" -eq 0 ]; then
        end_line=$line_num
    fi
    
    # Extract section content if found
    if [ "$start_line" -gt 0 ] && [ "$end_line" -gt "$start_line" ]; then
        # Extract lines from start_line+1 to end_line (skip the heading itself)
        section_content=$(sed -n "$((start_line + 1)),${end_line}p" "$INTAKE_FILE" 2>/dev/null || echo "")
    fi
    
    # Remove empty lines and template placeholders
    # Template placeholders typically look like: [description], [text], etc.
    # But exclude markdown links: [text](url) should not be considered placeholders
    # Pattern: lines that are ONLY [something] (not markdown links or other content)
    section_content=$(echo "$section_content" | grep -vE '^[[:space:]]*$' | grep -vE '^[[:space:]]*\[[^]]+\][[:space:]]*$' || echo "")
    
    # Further filter: exclude lines that are ONLY placeholders with common patterns
    # Keep lines that have actual text content (not just brackets)
    section_content=$(echo "$section_content" | grep -vE '^[[:space:]]*\[(Describe|Fill|Add|Enter|Specify|List|Provide|Include|TODO|FIXME|TBD)[^\]]*\][[:space:]]*$' || echo "$section_content")
    
    # Check if there's any real content left
    if [ -z "$section_content" ]; then
        echo -e "${RED}Error: Section '${section_name}' is empty or contains only template placeholders${NC}"
        echo -e "${RED}  Action: Fill the '## ${section_name}' section with actual content${NC}"
        ERRORS=$((ERRORS + 1))
        return 1
    fi
    return 0
}

# Check critical sections for content
if echo "$HEADINGS" | grep -qiE "^Goal$"; then
    check_section_content "Goal"
fi

if echo "$HEADINGS" | grep -qiE "^Scope$"; then
    check_section_content "Scope"
fi

if echo "$HEADINGS" | grep -qiE "^Definition of Done$|^Definition of done$"; then
    check_section_content "Definition of Done"
fi

# Summary
echo ""
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ INTAKE.md validation passed: All required sections present and non-empty${NC}"
    exit 0
else
    echo -e "${RED}✗ INTAKE.md validation failed: ${ERRORS} error(s)${NC}"
    echo -e "${RED}  Action: Fix the errors above and rerun validation${NC}"
    exit 1
fi
