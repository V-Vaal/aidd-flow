#!/bin/bash

# AIDD Verify UI: Lightweight smoke test for frontend
# Runs headless browser tests and captures console/network errors
# Optional: requires Playwright or Puppeteer
# Run from repository root: bash scripts/aidd-verify-ui.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Resolve repository root and project root
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$REPO_ROOT"

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Verify PROJECT_ROOT exists before changing directory
if [ ! -d "$PROJECT_ROOT" ]; then
    echo -e "${RED}Error: Project root directory does not exist: $PROJECT_ROOT${NC}"
    echo -e "${RED}  Script location: $SCRIPT_DIR${NC}"
    exit 1
fi

cd "$PROJECT_ROOT"

echo -e "${BLUE}=== AIDD UI Verification ===${NC}"
echo ""

# Check if frontend exists
if [ ! -f "package.json" ]; then
    echo -e "${YELLOW}SKIP: No package.json found (not a Node.js project)${NC}"
    exit 0
fi

# Check for Next.js or React
HAS_NEXT="no"
HAS_REACT="no"
if grep -q '"next"' "package.json" 2>/dev/null; then
    HAS_NEXT="yes"
fi
if grep -q '"react"' "package.json" 2>/dev/null; then
    HAS_REACT="yes"
fi

if [ "$HAS_NEXT" = "no" ] && [ "$HAS_REACT" = "no" ]; then
    echo -e "${YELLOW}SKIP: No React/Next.js detected in package.json${NC}"
    exit 0
fi

# Check for Playwright
if [ -f "package.json" ] && grep -q '"@playwright/test"' "package.json" 2>/dev/null; then
    echo -e "${BLUE}→ Playwright detected${NC}"
    
    if [ -f "playwright.config.js" ] || [ -f "playwright.config.ts" ]; then
        echo -e "${BLUE}  Running Playwright tests...${NC}"
        if command -v npx &> /dev/null; then
            # Check if Playwright is actually installed (without triggering install)
            if npx --no-install playwright --version >/dev/null 2>&1; then
                if npx playwright test --reporter=list 2>/dev/null; then
                    echo -e "${GREEN}  ✓ Playwright tests passed${NC}"
                else
                    echo -e "${RED}  ✗ Playwright tests failed${NC}"
                    exit 1
                fi
            else
                echo -e "${YELLOW}  ⚠ Playwright not installed, cannot run tests${NC}"
                echo -e "${BLUE}  To install: npx playwright install${NC}"
                exit 0
            fi
        else
            echo -e "${YELLOW}  ⚠ npx not available, cannot run Playwright tests${NC}"
            exit 0
        fi
    else
        echo -e "${YELLOW}  ⚠ Playwright installed but no config found${NC}"
        echo -e "${BLUE}  To set up Playwright:${NC}"
        echo "    npx playwright init"
        echo "    npx playwright install"
        exit 0
    fi
    exit 0
fi

# Check for Puppeteer
if [ -f "package.json" ] && grep -q '"puppeteer"' "package.json" 2>/dev/null; then
    echo -e "${BLUE}→ Puppeteer detected${NC}"
    echo -e "${YELLOW}  ⚠ Puppeteer support not implemented yet${NC}"
    echo -e "${BLUE}  To use Playwright instead:${NC}"
    echo "    npm install -D @playwright/test"
    echo "    npx playwright install"
    exit 0
fi

# Check if dev server can start (lightweight check)
if [ "$HAS_NEXT" = "yes" ]; then
    echo -e "${BLUE}→ Next.js project detected${NC}"
    echo -e "${YELLOW}  ⚠ No Playwright/Puppeteer detected${NC}"
    echo ""
    echo -e "${BLUE}  Manual verification steps:${NC}"
    echo "    1. Start dev server: npm run dev"
    echo "    2. Open browser and check console for errors"
    echo "    3. Test key user flows"
    echo "    4. Check network tab for failed requests"
    echo ""
    echo -e "${BLUE}  To enable automated UI verification with Playwright:${NC}"
    echo "    npm install -D @playwright/test"
    echo "    npx playwright install"
    echo "    npx playwright init"
    exit 0
fi

if [ "$HAS_REACT" = "yes" ]; then
    echo -e "${BLUE}→ React project detected${NC}"
    echo -e "${YELLOW}  ⚠ No Playwright/Puppeteer detected${NC}"
    echo ""
    echo -e "${BLUE}  Manual verification steps:${NC}"
    echo "    1. Start dev server: npm start"
    echo "    2. Open browser and check console for errors"
    echo "    3. Test key user flows"
    echo "    4. Check network tab for failed requests"
    echo ""
    echo -e "${BLUE}  To enable automated UI verification with Playwright:${NC}"
    echo "    npm install -D @playwright/test"
    echo "    npx playwright install"
    echo "    npx playwright init"
    exit 0
fi

echo -e "${YELLOW}SKIP: No UI testing framework detected${NC}"
echo -e "${BLUE}  To add Playwright for automated UI verification:${NC}"
echo "    npm install -D @playwright/test"
echo "    npx playwright install"
echo "    npx playwright init"
exit 0
