#!/bin/bash

# AIDD Export: Install AIDD workflow into a target project
# Usage: aidd-export.sh <target-project-path> [--backup]
#
# Copies from repository root:
#   - .cursor/rules/     → <target>/.cursor/rules/
#   - .cursor/commands/  → <target>/.cursor/commands/
#   - .cursor/prompts/   → <target>/.cursor/prompts/
#   - .cursor/memory/    → <target>/.cursor/memory/ (templates)
#   - .cursor/work/      → <target>/.cursor/work/ (templates)
#   - .cursor/review/    → <target>/.cursor/review/
#   - scripts/*.sh       → <target>/.cursor/scripts/
#   - docs/*.md          → <target>/.cursor/docs/
#
# Creates:
#   - <target>/.cursor/aidd.lock  (timestamp, source info, commit sha)

set -euo pipefail

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get script directory (scripts/ at repository root or .cursor/scripts/ in target)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detect if we're in scripts/ (repository root) or .cursor/scripts/ (target project)
# This script should be run from scripts/ at repository root
if [ "$(basename "$(dirname "$SCRIPT_DIR")")" = ".cursor" ]; then
    # Running from .cursor/scripts/ (target project - unexpected but handle gracefully)
    CURSOR_DIR="$(dirname "$SCRIPT_DIR")"
    REPO_ROOT="$(cd "$CURSOR_DIR/.." && pwd)"
    echo -e "${YELLOW}Warning: This script is typically run from scripts/ at repository root${NC}"
    echo -e "${YELLOW}  Detected location: .cursor/scripts/${NC}"
    echo -e "${YELLOW}  Assuming repository root is: ${REPO_ROOT}${NC}"
else
    # Running from scripts/ at repository root (expected)
    REPO_ROOT="$(dirname "$SCRIPT_DIR")"
fi

# Parse arguments
TARGET_PATH="${1:-}"
BACKUP_FLAG="${2:-}"

if [ -z "$TARGET_PATH" ]; then
    echo -e "${RED}Error: Target project path required${NC}"
    echo "Usage: $0 <target-project-path> [--backup]"
    exit 1
fi

# Resolve target path (handle relative paths)
if [ ! -d "$TARGET_PATH" ]; then
    echo -e "${RED}Error: Target directory does not exist: $TARGET_PATH${NC}"
    exit 1
fi

TARGET_ROOT="$(cd "$TARGET_PATH" && pwd)"
TARGET_CURSOR="$TARGET_ROOT/.cursor"

# Check if source directories exist (with helpful error messages)
if [ ! -d "$REPO_ROOT/.cursor/rules" ]; then
    echo -e "${RED}Error: Source rules directory not found: $REPO_ROOT/.cursor/rules${NC}"
    echo -e "${RED}  Script location: ${SCRIPT_DIR}${NC}"
    echo -e "${RED}  Expected repository structure: $REPO_ROOT/.cursor/rules/${NC}"
    echo -e "${RED}  This script should be run from scripts/ at repository root${NC}"
    exit 1
fi

if [ ! -d "$REPO_ROOT/scripts" ]; then
    echo -e "${RED}Error: Source scripts directory not found: $REPO_ROOT/scripts${NC}"
    echo -e "${RED}  Script location: ${SCRIPT_DIR}${NC}"
    echo -e "${RED}  Expected repository structure: $REPO_ROOT/scripts/${NC}"
    exit 1
fi

if [ ! -d "$REPO_ROOT/docs" ]; then
    echo -e "${RED}Error: Source docs directory not found: $REPO_ROOT/docs${NC}"
    echo -e "${RED}  Script location: ${SCRIPT_DIR}${NC}"
    echo -e "${RED}  Expected repository structure: $REPO_ROOT/docs/${NC}"
    exit 1
fi

echo -e "${BLUE}=== AIDD Export ===${NC}"
echo "Source: $REPO_ROOT"
echo "Target: $TARGET_ROOT"
echo ""

# Backup existing .cursor if requested and exists
if [ "$BACKUP_FLAG" = "--backup" ] && [ -d "$TARGET_CURSOR" ]; then
    BACKUP_DIR="$TARGET_CURSOR.bak-$(date +%Y%m%d-%H%M%S)"
    echo -e "${YELLOW}Backing up existing .cursor to: $BACKUP_DIR${NC}"
    cp -r "$TARGET_CURSOR" "$BACKUP_DIR"
    echo -e "${GREEN}✓ Backup created${NC}"
    echo ""
fi

# Create .cursor directory structure
mkdir -p "$TARGET_CURSOR/rules"
mkdir -p "$TARGET_CURSOR/commands"
mkdir -p "$TARGET_CURSOR/prompts"
mkdir -p "$TARGET_CURSOR/memory"
mkdir -p "$TARGET_CURSOR/work"
mkdir -p "$TARGET_CURSOR/review"
mkdir -p "$TARGET_CURSOR/scripts"
mkdir -p "$TARGET_CURSOR/docs"

# Copy rules (preserve directory structure, idempotent)
echo -e "${BLUE}[1/8] Copying rules...${NC}"
if command -v rsync &> /dev/null; then
    if ! rsync -a --delete "$REPO_ROOT/.cursor/rules/" "$TARGET_CURSOR/rules/" 2>&1; then
        echo -e "${YELLOW}  Warning: rsync failed, using fallback${NC}"
        rm -rf "$TARGET_CURSOR/rules"
        mkdir -p "$TARGET_CURSOR/rules"
        cp -a "$REPO_ROOT/.cursor/rules"/* "$TARGET_CURSOR/rules/" 2>/dev/null || true
    fi
else
    # Fallback: idempotent copy using tar pipe if available, else remove + cp -a
    if command -v tar &> /dev/null; then
        # Remove target directory and recreate from source using tar pipe
        rm -rf "$TARGET_CURSOR/rules"
        mkdir -p "$TARGET_CURSOR/rules"
        if ! (cd "$REPO_ROOT/.cursor/rules" && tar cf - . 2>/dev/null | (cd "$TARGET_CURSOR/rules" && tar xf - 2>/dev/null)); then
            # Tar pipe failed, use cp -a fallback
            rm -rf "$TARGET_CURSOR/rules"
            cp -a "$REPO_ROOT/.cursor/rules" "$TARGET_CURSOR/"
        fi
    else
        # Final fallback: remove + cp -a
        rm -rf "$TARGET_CURSOR/rules"
        cp -a "$REPO_ROOT/.cursor/rules" "$TARGET_CURSOR/"
    fi
fi
RULES_COUNT=$(find "$TARGET_CURSOR/rules" -name "*.mdc" -type f 2>/dev/null | wc -l | tr -d ' ' || echo "0")
echo -e "${GREEN}✓ Copied ${RULES_COUNT} rule files${NC}"
echo ""

# Copy commands (preserve directory structure, idempotent)
if [ -d "$REPO_ROOT/.cursor/commands" ]; then
    echo -e "${BLUE}[2/8] Copying commands...${NC}"
    if command -v rsync &> /dev/null; then
        if ! rsync -a --delete "$REPO_ROOT/.cursor/commands/" "$TARGET_CURSOR/commands/" 2>&1; then
            echo -e "${YELLOW}  Warning: rsync failed, using fallback${NC}"
            rm -rf "$TARGET_CURSOR/commands"
            mkdir -p "$TARGET_CURSOR/commands"
            cp -a "$REPO_ROOT/.cursor/commands"/* "$TARGET_CURSOR/commands/" 2>/dev/null || true
        fi
    else
        # Fallback: remove old files, then copy new ones
        rm -rf "$TARGET_CURSOR/commands"
        mkdir -p "$TARGET_CURSOR/commands"
        if [ -d "$REPO_ROOT/.cursor/commands" ]; then
            cp -a "$REPO_ROOT/.cursor/commands"/* "$TARGET_CURSOR/commands/" 2>/dev/null || true
        fi
    fi
    COMMANDS_COUNT=$(find "$TARGET_CURSOR/commands" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ' || echo "0")
    echo -e "${GREEN}✓ Copied ${COMMANDS_COUNT} command files${NC}"
    echo ""
fi

# Copy prompts (preserve directory structure, idempotent)
if [ -d "$REPO_ROOT/.cursor/prompts" ]; then
    echo -e "${BLUE}[3/8] Copying prompts...${NC}"
    if command -v rsync &> /dev/null; then
        if ! rsync -a --delete "$REPO_ROOT/.cursor/prompts/" "$TARGET_CURSOR/prompts/" 2>&1; then
            echo -e "${YELLOW}  Warning: rsync failed, using fallback${NC}"
            rm -rf "$TARGET_CURSOR/prompts"
            mkdir -p "$TARGET_CURSOR/prompts"
            cp -a "$REPO_ROOT/.cursor/prompts"/* "$TARGET_CURSOR/prompts/" 2>/dev/null || true
        fi
    else
        # Fallback: remove old files, then copy new ones
        rm -rf "$TARGET_CURSOR/prompts"
        mkdir -p "$TARGET_CURSOR/prompts"
        if [ -d "$REPO_ROOT/.cursor/prompts" ]; then
            cp -a "$REPO_ROOT/.cursor/prompts"/* "$TARGET_CURSOR/prompts/" 2>/dev/null || true
        fi
    fi
    PROMPTS_COUNT=$(find "$TARGET_CURSOR/prompts" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ' || echo "0")
    echo -e "${GREEN}✓ Copied ${PROMPTS_COUNT} prompt files${NC}"
    echo ""
fi

# Copy memory templates (idempotent)
if [ -d "$REPO_ROOT/.cursor/memory" ]; then
    echo -e "${BLUE}[4/8] Copying memory templates...${NC}"
    if command -v rsync &> /dev/null; then
        rsync -a "$REPO_ROOT/.cursor/memory/" "$TARGET_CURSOR/memory/" 2>&1 || cp -a "$REPO_ROOT/.cursor/memory"/* "$TARGET_CURSOR/memory/" 2>/dev/null || true
    else
        cp -a "$REPO_ROOT/.cursor/memory"/* "$TARGET_CURSOR/memory/" 2>/dev/null || true
    fi
    MEMORY_COUNT=$(find "$TARGET_CURSOR/memory" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ' || echo "0")
    echo -e "${GREEN}✓ Copied ${MEMORY_COUNT} memory template files${NC}"
    echo ""
fi

# Copy work templates (idempotent)
if [ -d "$REPO_ROOT/.cursor/work" ]; then
    echo -e "${BLUE}[5/8] Copying work templates...${NC}"
    if command -v rsync &> /dev/null; then
        rsync -a "$REPO_ROOT/.cursor/work/" "$TARGET_CURSOR/work/" 2>&1 || cp -a "$REPO_ROOT/.cursor/work"/* "$TARGET_CURSOR/work/" 2>/dev/null || true
    else
        cp -a "$REPO_ROOT/.cursor/work"/* "$TARGET_CURSOR/work/" 2>/dev/null || true
    fi
    WORK_COUNT=$(find "$TARGET_CURSOR/work" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ' || echo "0")
    echo -e "${GREEN}✓ Copied ${WORK_COUNT} work template files${NC}"
    echo ""
fi

# Copy review checklists (idempotent)
if [ -d "$REPO_ROOT/.cursor/review" ]; then
    echo -e "${BLUE}[6/8] Copying review checklists...${NC}"
    if command -v rsync &> /dev/null; then
        rsync -a "$REPO_ROOT/.cursor/review/" "$TARGET_CURSOR/review/" 2>&1 || cp -a "$REPO_ROOT/.cursor/review"/* "$TARGET_CURSOR/review/" 2>/dev/null || true
    else
        cp -a "$REPO_ROOT/.cursor/review"/* "$TARGET_CURSOR/review/" 2>/dev/null || true
    fi
    REVIEW_COUNT=$(find "$TARGET_CURSOR/review" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ' || echo "0")
    echo -e "${GREEN}✓ Copied ${REVIEW_COUNT} review checklist files${NC}"
    echo ""
fi

# Copy scripts (make executable, idempotent)
echo -e "${BLUE}[7/8] Copying scripts...${NC}"
# Remove target scripts directory for idempotency
rm -rf "$TARGET_CURSOR/scripts"
mkdir -p "$TARGET_CURSOR/scripts"

# Copy all scripts from source
while IFS= read -r -d '' script; do
    script_name=$(basename "$script")
    cp "$script" "$TARGET_CURSOR/scripts/$script_name"
    chmod +x "$TARGET_CURSOR/scripts/$script_name"
    echo -e "  ✓ $script_name"
done < <(find "$REPO_ROOT/scripts" -name "*.sh" -type f -print0 2>/dev/null || true)

SCRIPTS_COUNT=$(find "$TARGET_CURSOR/scripts" -name "*.sh" -type f 2>/dev/null | wc -l | tr -d ' ' || echo "0")
echo -e "${GREEN}✓ Copied ${SCRIPTS_COUNT} scripts${NC}"
echo ""

# Copy docs (idempotent)
echo -e "${BLUE}[8/8] Copying documentation...${NC}"
# Remove target docs directory for idempotency
rm -rf "$TARGET_CURSOR/docs"
mkdir -p "$TARGET_CURSOR/docs"

# Copy all docs from source
while IFS= read -r -d '' doc; do
    doc_name=$(basename "$doc")
    cp "$doc" "$TARGET_CURSOR/docs/$doc_name"
    echo -e "  ✓ $doc_name"
done < <(find "$REPO_ROOT/docs" -name "*.md" -type f -print0 2>/dev/null || true)

DOCS_COUNT=$(find "$TARGET_CURSOR/docs" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ' || echo "0")
echo -e "${GREEN}✓ Copied ${DOCS_COUNT} documentation files${NC}"
echo ""

# Create aidd.lock
echo -e "${BLUE}Creating aidd.lock...${NC}"
LOCK_FILE="$TARGET_CURSOR/aidd.lock"

# Get source repo info using git -C for robust repo root detection
SOURCE_REMOTE="unknown"
SOURCE_COMMIT="uncommitted"
TEMPLATE_VERSION="1.0.0"

# Determine git repo root: check template dir, then parent (AIDD repo root)
GIT_REPO_ROOT=""
if [ -d "$REPO_ROOT/.git" ]; then
    GIT_REPO_ROOT="$REPO_ROOT"
elif [ -d "$(dirname "$REPO_ROOT")/.git" ]; then
    GIT_REPO_ROOT="$(dirname "$REPO_ROOT")"
fi

# Collect git metadata if repo found and git is available (never fail if missing)
if [ -n "$GIT_REPO_ROOT" ] && [ -d "$GIT_REPO_ROOT/.git" ] && command -v git &> /dev/null; then
    SOURCE_REMOTE=$(git -C "$GIT_REPO_ROOT" remote get-url origin 2>/dev/null || echo "unknown")
    
    # Try to get commit SHA, use "uncommitted" if no valid commit
    if git -C "$GIT_REPO_ROOT" rev-parse HEAD >/dev/null 2>&1; then
        SOURCE_COMMIT=$(git -C "$GIT_REPO_ROOT" rev-parse HEAD 2>/dev/null)
    fi
fi

# Read template version from VERSION file if it exists
if [ -f "$REPO_ROOT/VERSION" ]; then
    TEMPLATE_VERSION=$(tr -d '[:space:]' < "$REPO_ROOT/VERSION")
elif [ -n "$GIT_REPO_ROOT" ] && [ -f "$GIT_REPO_ROOT/VERSION" ]; then
    TEMPLATE_VERSION=$(tr -d '[:space:]' < "$GIT_REPO_ROOT/VERSION")
fi

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Generate lock file content, omitting lines with "unknown" values
{
    echo "# AIDD Lock File"
    echo "# Generated: $TIMESTAMP"
    echo "# This file tracks the AIDD template version installed in this project"
    echo ""
    echo "timestamp: $TIMESTAMP"
    if [ "$SOURCE_REMOTE" != "unknown" ]; then
        echo "source_remote: $SOURCE_REMOTE"
    fi
    echo "source_commit: $SOURCE_COMMIT"
    echo "template_version: $TEMPLATE_VERSION"
} > "$LOCK_FILE"

echo -e "${GREEN}✓ Created aidd.lock${NC}"
echo ""

# Summary
echo -e "${BLUE}=== Export Summary ===${NC}"
echo -e "${GREEN}✓ Rules:     ${RULES_COUNT} files${NC}"
if [ -d "$TARGET_CURSOR/commands" ]; then
    echo -e "${GREEN}✓ Commands:  ${COMMANDS_COUNT:-0} files${NC}"
fi
if [ -d "$TARGET_CURSOR/prompts" ]; then
    echo -e "${GREEN}✓ Prompts:   ${PROMPTS_COUNT:-0} files${NC}"
fi
if [ -d "$TARGET_CURSOR/memory" ]; then
    echo -e "${GREEN}✓ Memory:    ${MEMORY_COUNT:-0} template files${NC}"
fi
if [ -d "$TARGET_CURSOR/work" ]; then
    echo -e "${GREEN}✓ Work:      ${WORK_COUNT:-0} template files${NC}"
fi
if [ -d "$TARGET_CURSOR/review" ]; then
    echo -e "${GREEN}✓ Review:    ${REVIEW_COUNT:-0} checklist files${NC}"
fi
echo -e "${GREEN}✓ Scripts:   ${SCRIPTS_COUNT} files${NC}"
echo -e "${GREEN}✓ Docs:      ${DOCS_COUNT} files${NC}"
echo -e "${GREEN}✓ Lock file: Created${NC}"
echo ""
echo -e "${BLUE}Installation complete!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Review docs/workflow.md for usage instructions"
echo "  2. Run: bash .cursor/scripts/validate-rules.sh"
echo "  3. Run: bash .cursor/scripts/aidd-context.sh (to generate context)"
echo "  4. Run: bash .cursor/scripts/aidd-check.sh (to validate project)"
echo ""

# ============================================================================
# VERIFICATION PLAN
# ============================================================================
# To verify the export works correctly:
#
# 1. Export into a test directory:
#    cd /path/to/aidd-flow
#    bash scripts/aidd-export.sh ./tmp-target
#
# 2. Check files exist in .cursor/:
#    ls -la tmp-target/.cursor/
#    ls -la tmp-target/.cursor/rules/
#    ls -la tmp-target/.cursor/scripts/
#    ls -la tmp-target/.cursor/docs/
#    cat tmp-target/.cursor/aidd.lock
#
# 3. Run validate-rules.sh from target project:
#    cd tmp-target
#    bash .cursor/scripts/validate-rules.sh
#    # Should validate rules in tmp-target/.cursor/rules/
#
# 4. Run aidd-context.sh from target project:
#    cd tmp-target
#    bash .cursor/scripts/aidd-context.sh
#    # Should print context bundle without errors
#
# 5. Test idempotency (re-run export):
#    cd /path/to/aidd-flow
#    bash scripts/aidd-export.sh ./tmp-target
#    # Should update files cleanly without errors
#
# 6. Test idempotency with stray file:
#    touch tmp-target/.cursor/rules/stray-file.mdc
#    bash scripts/aidd-export.sh ./tmp-target
#    # stray-file.mdc should be removed
#
# 7. Run aidd-check.sh from target project:
#    cd tmp-target
#    bash .cursor/scripts/aidd-check.sh
#
# 8. Run aidd-check.sh from repository root:
#    cd /path/to/aidd-flow
#    bash scripts/aidd-check.sh
#    # Should show repository mode message
#
# 9. Cleanup:
#    rm -rf tmp-target
# ============================================================================
