#!/bin/bash

# Smoke test for aidd-context.sh
# Validates that:
# - Script runs without errors in default and verbose modes
# - Default mode excludes Memory Bank (no empty template dumps)
# - Verbose mode includes Memory Bank
# - Output contains expected markers
#
# Uses a controlled temporary workspace to ensure deterministic behavior.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTEXT_SCRIPT="$SCRIPT_DIR/aidd-context.sh"

ERRORS=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo "=== Testing aidd-context.sh ==="
echo ""

# Create temporary workspace with controlled structure
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

# Setup temp workspace structure for testing
# Note: This creates a temporary test project layout (test_project/) to simulate
# a repository structure.
# It's purely a test fixture and does not represent the actual repository structure.
mkdir -p "$TMPDIR/test_project/scripts"
mkdir -p "$TMPDIR/test_project/aidd/memory"

# Copy script under test into temp workspace
cp "$CONTEXT_SCRIPT" "$TMPDIR/test_project/scripts/aidd-context.sh"
chmod +x "$TMPDIR/test_project/scripts/aidd-context.sh"

# Create a memory file with recognizable test marker
echo "TEST_MEMORY_BANK" > "$TMPDIR/test_project/aidd/memory/projectbrief.md"

# Output files in temp workspace
DEFAULT_OUT="$TMPDIR/default.out"
VERBOSE_OUT="$TMPDIR/verbose.out"

# Test 1: Default mode runs successfully
echo "[1/9] Testing default mode execution..."
if bash "$TMPDIR/test_project/scripts/aidd-context.sh" > "$DEFAULT_OUT" 2>&1; then
    echo -e "${GREEN}✓ Default mode executed successfully${NC}"
else
    echo -e "${RED}✗ Default mode failed${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Test 2: Default mode excludes Memory Bank section
echo "[2/9] Testing default mode excludes Memory Bank section..."
if grep -q "=== Memory Bank ===" "$DEFAULT_OUT"; then
    echo -e "${RED}✗ Default mode should NOT include Memory Bank section${NC}"
    echo "  Found at line: $(grep -n '=== Memory Bank ===' "$DEFAULT_OUT" | head -1)"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}✓ Default mode correctly excludes Memory Bank section${NC}"
fi

# Test 3: Default mode excludes Memory Bank content
echo "[3/9] Testing default mode excludes Memory Bank content..."
if grep -q "TEST_MEMORY_BANK" "$DEFAULT_OUT"; then
    echo -e "${RED}✗ Default mode should NOT include Memory Bank content${NC}"
    echo "  Found at line: $(grep -n 'TEST_MEMORY_BANK' "$DEFAULT_OUT" | head -1)"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}✓ Default mode correctly excludes Memory Bank content${NC}"
fi

# Test 4: Default mode includes Memory Bank signal line
echo "[4/9] Testing default mode includes Memory Bank signal line..."
if grep -q "Memory Bank: present (" "$DEFAULT_OUT"; then
    echo -e "${GREEN}✓ Default mode correctly includes Memory Bank signal line${NC}"
else
    echo -e "${RED}✗ Default mode MUST include Memory Bank signal line${NC}"
    echo "  Expected 'Memory Bank: present (' not found in default output"
    ERRORS=$((ERRORS + 1))
fi

# Test 5: Verbose mode runs successfully
echo "[5/9] Testing verbose mode execution..."
if bash "$TMPDIR/test_project/scripts/aidd-context.sh" --verbose > "$VERBOSE_OUT" 2>&1; then
    echo -e "${GREEN}✓ Verbose mode executed successfully${NC}"
else
    echo -e "${RED}✗ Verbose mode failed${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Test 6: Verbose mode includes Memory Bank section (STRICT)
echo "[6/9] Testing verbose mode includes Memory Bank section..."
if grep -q "=== Memory Bank ===" "$VERBOSE_OUT"; then
    echo -e "${GREEN}✓ Verbose mode correctly includes Memory Bank section${NC}"
else
    echo -e "${RED}✗ Verbose mode MUST include Memory Bank section${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Test 7: Verbose mode includes Memory Bank content (STRICT)
echo "[7/9] Testing verbose mode includes Memory Bank content..."
if grep -q "TEST_MEMORY_BANK" "$VERBOSE_OUT"; then
    echo -e "${GREEN}✓ Verbose mode correctly includes Memory Bank content${NC}"
else
    echo -e "${RED}✗ Verbose mode MUST include Memory Bank content${NC}"
    echo "  Expected 'TEST_MEMORY_BANK' not found in verbose output"
    ERRORS=$((ERRORS + 1))
fi

# Test 8: Output contains expected markers
echo "[8/9] Testing output contains expected markers..."
if grep -q "=== AIDD Context Bundle ===" "$DEFAULT_OUT" && \
   grep -q "=== End of Context Bundle ===" "$DEFAULT_OUT" && \
   grep -q "Mode: concise" "$DEFAULT_OUT"; then
    echo -e "${GREEN}✓ Output contains expected markers${NC}"
else
    echo -e "${RED}✗ Output missing expected markers${NC}"
    if ! grep -q "=== AIDD Context Bundle ===" "$DEFAULT_OUT"; then
        echo "  Missing: === AIDD Context Bundle ==="
    fi
    if ! grep -q "=== End of Context Bundle ===" "$DEFAULT_OUT"; then
        echo "  Missing: === End of Context Bundle ==="
    fi
    if ! grep -q "Mode: concise" "$DEFAULT_OUT"; then
        echo "  Missing: Mode: concise"
    fi
    ERRORS=$((ERRORS + 1))
fi

# Test 9: Verbose mode contains verbose marker
echo "[9/9] Testing verbose mode contains verbose marker..."
if grep -q "Mode: verbose" "$VERBOSE_OUT"; then
    echo -e "${GREEN}✓ Verbose mode contains verbose marker${NC}"
else
    echo -e "${RED}✗ Verbose mode missing verbose marker${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Summary
echo ""
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed${NC}"
    exit 0
else
    echo -e "${RED}✗ Tests failed: ${ERRORS} error(s)${NC}"
    exit 1
fi
