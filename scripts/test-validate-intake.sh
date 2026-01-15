#!/bin/bash

# Test Harness for validate-intake.sh
#
# Purpose:
#   Tests Goal section detection robustness in validate-intake.sh
#   Validates that Goal section is correctly identified regardless of:
#   - Position in document (first, middle, last)
#   - Presence of subsections (###)
#   - Content type (real text vs template placeholders)
#
# Usage:
#   From template directory: bash scripts/test-validate-intake.sh
#   Or make executable: chmod +x scripts/test-validate-intake.sh && ./scripts/test-validate-intake.sh
#
# Expected Output:
#   - Runs 7 test cases
#   - Shows PASS/FAIL for each test
#   - Prints summary: Passed: X, Failed: Y
#   - Exits with code 0 if all tests pass, 1 if any fail
#
# Test Cases:
#   1. Goal with real content (should pass)
#   2. Goal with template placeholder (should fail)
#   3. Goal as last section (should pass)
#   4. Goal with subsections (should pass)
#   5. Goal empty (should fail)
#   6. Goal with markdown link (should pass - not placeholder)
#   7. Goal with list containing brackets (should pass)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALIDATOR="$SCRIPT_DIR/validate-intake.sh"

# Resolve test directory relative to script location
# Case A: target project: <project>/.cursor/scripts/test-validate-intake.sh
#         → work dir is <project>/.cursor/work (parent of scripts/, sibling of rules/)
# Case B: template repo: template/scripts/test-validate-intake.sh
#         → work dir is template/.cursor/work (sibling of scripts/)
if [ "$(basename "$(dirname "$SCRIPT_DIR")")" = ".cursor" ]; then
    # Case A: Running from target project
    CURSOR_DIR="$(dirname "$SCRIPT_DIR")"
    TEST_DIR="$CURSOR_DIR/work"
else
    # Case B: Running from template
    TEMPLATE_DIR="$(dirname "$SCRIPT_DIR")"
    TEST_DIR="$TEMPLATE_DIR/.cursor/work"
fi

ORIGINAL_INTAKE="$TEST_DIR/INTAKE.md"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Ensure test directory exists
mkdir -p "$TEST_DIR"

# Backup original if exists
BACKUP=""
if [ -f "$ORIGINAL_INTAKE" ]; then
    BACKUP=$(mktemp "$ORIGINAL_INTAKE.backup.XXXXXX") || exit 1
    cp "$ORIGINAL_INTAKE" "$BACKUP"
    echo -e "${YELLOW}Backed up original INTAKE.md to $BACKUP${NC}"
fi

TESTS_PASSED=0
TESTS_FAILED=0

test_case() {
    local name="$1"
    local content="$2"
    local should_pass="$3"  # "pass" or "fail"
    
    echo -e "\n${YELLOW}Test: $name${NC}"
    echo "$content" > "$ORIGINAL_INTAKE"
    
    local tmp_output
    tmp_output=$(mktemp) || exit 1
    
    if bash "$VALIDATOR" > "$tmp_output" 2>&1; then
        result="pass"
    else
        result="fail"
    fi
    
    if [ "$result" = "$should_pass" ]; then
        echo -e "${GREEN}✓ PASS${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ FAIL (expected $should_pass, got $result)${NC}"
        echo "Output:"
        cat "$tmp_output"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    
    rm -f "$tmp_output"
}

# Test cases
echo "Running validate-intake.sh test suite..."

# Case 1: Goal with real content (should pass)
test_case "Goal with real content" \
"**Artefact Status**: DRAFT
**Change Class**: A

## Goal

Implement EAS attestation resolver to support schema validation.

## Scope
Test scope

## Definition of Done
Test DoD

## Risks
Test risks

## Evidence Requirements
Test evidence" \
"pass"

# Case 2: Goal with template placeholder (should fail)
test_case "Goal with template placeholder" \
"**Artefact Status**: DRAFT
**Change Class**: A

## Goal

[Describe the goal of this change]

## Scope
Test scope

## Definition of Done
Test DoD

## Risks
Test risks

## Evidence Requirements
Test evidence" \
"fail"

# Case 3: Goal as last section (should pass)
test_case "Goal as last section" \
"**Artefact Status**: DRAFT
**Change Class**: A

## Scope
Test scope

## Risks
Test risks

## Goal

Implement EAS attestation resolver to support schema validation." \
"pass"

# Case 4: Goal with subsections (should pass)
test_case "Goal with subsections" \
"**Artefact Status**: DRAFT
**Change Class**: A

## Goal

Implement EAS attestation resolver.

### Sub-goal 1
Support schema validation.

### Sub-goal 2
Enable migration workflows.

## Scope
Test scope

## Definition of Done
Test DoD

## Risks
Test risks

## Evidence Requirements
Test evidence" \
"pass"

# Case 5: Goal empty (should fail)
test_case "Goal empty" \
"**Artefact Status**: DRAFT
**Change Class**: A

## Goal


## Scope
Test scope

## Definition of Done
Test DoD

## Risks
Test risks

## Evidence Requirements
Test evidence" \
"fail"

# Case 6: Goal with markdown link (should pass - not a placeholder)
test_case "Goal with markdown link" \
"**Artefact Status**: DRAFT
**Change Class**: A

## Goal

See [documentation](https://example.com) for details.

## Scope
Test scope

## Definition of Done
Test DoD

## Risks
Test risks

## Evidence Requirements
Test evidence" \
"pass"

# Case 7: Goal with list containing brackets (should pass)
test_case "Goal with list containing brackets" \
"**Artefact Status**: DRAFT
**Change Class**: A

## Goal

- Implement feature [core]
- Add tests [optional]

## Scope
Test scope

## Definition of Done
Test DoD

## Risks
Test risks

## Evidence Requirements
Test evidence" \
"pass"

# Summary
echo -e "\n${YELLOW}Test Summary:${NC}"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"

# Restore original if backed up
if [ -n "${BACKUP:-}" ] && [ -f "$BACKUP" ]; then
    cp "$BACKUP" "$ORIGINAL_INTAKE"
    rm -f "$BACKUP"
    echo -e "${YELLOW}Restored original INTAKE.md${NC}"
fi

if [ $TESTS_FAILED -eq 0 ]; then
    exit 0
else
    exit 1
fi
