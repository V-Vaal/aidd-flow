#!/bin/bash

# AIDD Export: Install AIDD workflow into a target project
# Usage: aidd-export.sh <target-project-path> [--force|--backup] [--force-agents|--backup-agents]
#
# Default behavior:
# - Exports the current aidd-flow repo into <target>/.aidd-flow/
# - Creates a minimal AGENTS.md at target root that redirects to .aidd-flow/AGENTS.md
#
# Safety behavior:
# - If <target>/.aidd-flow exists and is non-empty: refuse unless --force or --backup is provided
# - If <target>/AGENTS.md exists: refuse unless --force-agents or --backup-agents is provided

set -euo pipefail

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

TARGET_PATH=""
FORCE=false
BACKUP=false
FORCE_AGENTS=false
BACKUP_AGENTS=false

print_usage() {
    echo "Usage: $0 <target-project-path> [--force|--backup] [--force-agents|--backup-agents]"
    echo ""
    echo "Flags:"
    echo "  --force          Overwrite non-empty .aidd-flow/ in target"
    echo "  --backup         Rename existing .aidd-flow/ to .aidd-flow.bak-<timestamp>"
    echo "  --force-agents   Overwrite existing AGENTS.md in target root"
    echo "  --backup-agents  Rename existing AGENTS.md to AGENTS.md.bak-<timestamp>"
}

for arg in "$@"; do
    case "$arg" in
        --force)
            FORCE=true
            ;;
        --backup)
            BACKUP=true
            ;;
        --force-agents)
            FORCE_AGENTS=true
            ;;
        --backup-agents)
            BACKUP_AGENTS=true
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            if [ -z "$TARGET_PATH" ]; then
                TARGET_PATH="$arg"
            else
                echo -e "${RED}Error: Unknown argument: $arg${NC}"
                print_usage
                exit 1
            fi
            ;;
    esac
done

if [ -z "$TARGET_PATH" ]; then
    echo -e "${RED}Error: Target project path required${NC}"
    print_usage
    exit 1
fi

if [ "$FORCE" = true ] && [ "$BACKUP" = true ]; then
    echo -e "${RED}Error: Use only one of --force or --backup${NC}"
    exit 1
fi

if [ "$FORCE_AGENTS" = true ] && [ "$BACKUP_AGENTS" = true ]; then
    echo -e "${RED}Error: Use only one of --force-agents or --backup-agents${NC}"
    exit 1
fi

if [ ! -d "$TARGET_PATH" ]; then
    echo -e "${RED}Error: Target directory does not exist: $TARGET_PATH${NC}"
    exit 1
fi

TARGET_ROOT="$(cd "$TARGET_PATH" && pwd)"
TARGET_AIDD="$TARGET_ROOT/.aidd-flow"
TARGET_AGENTS="$TARGET_ROOT/AGENTS.md"

if [ ! -d "$REPO_ROOT/scripts" ]; then
    echo -e "${RED}Error: Source scripts directory not found: $REPO_ROOT/scripts${NC}"
    exit 1
fi

is_dir_empty() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        return 0
    fi
    if find "$dir" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null | grep -q .; then
        return 1
    fi
    return 0
}

if [ -d "$TARGET_AIDD" ] && ! is_dir_empty "$TARGET_AIDD"; then
    if [ "$BACKUP" = true ]; then
        BACKUP_DIR="$TARGET_ROOT/.aidd-flow.bak-$(date +%Y%m%d-%H%M%S)"
        echo -e "${YELLOW}Backing up existing .aidd-flow/ to: $BACKUP_DIR${NC}"
        mv "$TARGET_AIDD" "$BACKUP_DIR"
    elif [ "$FORCE" = true ]; then
        echo -e "${YELLOW}Overwriting existing .aidd-flow/${NC}"
        rm -rf "$TARGET_AIDD"
    else
        echo -e "${RED}Error: .aidd-flow/ already exists and is not empty${NC}"
        echo -e "${RED}  Action: Use --force to overwrite or --backup to rename${NC}"
        exit 1
    fi
fi

if [ -f "$TARGET_AGENTS" ]; then
    if [ "$BACKUP_AGENTS" = true ]; then
        BACKUP_FILE="$TARGET_AGENTS.bak-$(date +%Y%m%d-%H%M%S)"
        echo -e "${YELLOW}Backing up existing AGENTS.md to: $BACKUP_FILE${NC}"
        mv "$TARGET_AGENTS" "$BACKUP_FILE"
    elif [ "$FORCE_AGENTS" = true ]; then
        echo -e "${YELLOW}Overwriting existing AGENTS.md${NC}"
    else
        echo -e "${RED}Error: AGENTS.md already exists at target root${NC}"
        echo -e "${RED}  Action: Use --force-agents to overwrite or --backup-agents to rename${NC}"
        exit 1
    fi
fi

mkdir -p "$TARGET_AIDD"

echo -e "${BLUE}=== AIDD Export ===${NC}"
echo "Source: $REPO_ROOT"
echo "Target: $TARGET_AIDD"
echo ""

copy_success=false

if command -v rsync &> /dev/null; then
    if rsync -a --delete --exclude ".git" "$REPO_ROOT/" "$TARGET_AIDD/" 2>&1; then
        copy_success=true
    else
        echo -e "${YELLOW}Warning: rsync failed, trying fallback${NC}"
    fi
fi

if [ "$copy_success" = false ]; then
    if command -v tar &> /dev/null; then
        if (cd "$REPO_ROOT" && tar cf - --exclude ".git" . 2>/dev/null | (cd "$TARGET_AIDD" && tar xf - 2>/dev/null)); then
            copy_success=true
        else
            echo -e "${YELLOW}Warning: tar fallback failed, trying cp${NC}"
        fi
    fi
fi

if [ "$copy_success" = false ]; then
    cp -a "$REPO_ROOT/." "$TARGET_AIDD/"
    if [ -d "$TARGET_AIDD/.git" ]; then
        rm -rf "$TARGET_AIDD/.git"
    fi
fi

LOCK_FILE="$TARGET_AIDD/aidd/aidd.lock"
mkdir -p "$(dirname "$LOCK_FILE")"

SOURCE_REMOTE="unknown"
SOURCE_COMMIT="uncommitted"
TEMPLATE_VERSION="1.0.0"

GIT_REPO_ROOT=""
if [ -d "$REPO_ROOT/.git" ]; then
    GIT_REPO_ROOT="$REPO_ROOT"
elif [ -d "$(dirname "$REPO_ROOT")/.git" ]; then
    GIT_REPO_ROOT="$(dirname "$REPO_ROOT")"
fi

if [ -n "$GIT_REPO_ROOT" ] && [ -d "$GIT_REPO_ROOT/.git" ] && command -v git &> /dev/null; then
    SOURCE_REMOTE=$(git -C "$GIT_REPO_ROOT" remote get-url origin 2>/dev/null || echo "unknown")
    if git -C "$GIT_REPO_ROOT" rev-parse HEAD >/dev/null 2>&1; then
        SOURCE_COMMIT=$(git -C "$GIT_REPO_ROOT" rev-parse HEAD 2>/dev/null)
    fi
fi

if [ -f "$REPO_ROOT/VERSION" ]; then
    TEMPLATE_VERSION=$(tr -d '[:space:]' < "$REPO_ROOT/VERSION")
elif [ -n "$GIT_REPO_ROOT" ] && [ -f "$GIT_REPO_ROOT/VERSION" ]; then
    TEMPLATE_VERSION=$(tr -d '[:space:]' < "$GIT_REPO_ROOT/VERSION")
fi

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

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

cat <<EOF > "$TARGET_AGENTS"
# AGENTS.md — project

This project uses aidd-flow installed under ".aidd-flow/".
Load ".aidd-flow/AGENTS.md" as the canonical workflow entry point.

Common commands:
- bash .aidd-flow/scripts/validate-plan.sh
- bash .aidd-flow/scripts/aidd-check.sh
- bash .aidd-flow/scripts/review-check.sh
- bash .aidd-flow/scripts/aidd-finish.sh
EOF

echo -e "${GREEN}✓ Export complete${NC}"
echo -e "${GREEN}✓ Created ${LOCK_FILE}${NC}"
echo -e "${GREEN}✓ Created ${TARGET_AGENTS}${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Review .aidd-flow/docs/workflow/README.md for usage instructions"
echo "  2. Run: bash .aidd-flow/scripts/validate-rules.sh"
echo "  3. Run: bash .aidd-flow/scripts/aidd-context.sh"
echo "  4. Run: bash .aidd-flow/scripts/aidd-check.sh"
echo ""
echo -e "${BLUE}Note:${NC}"
echo "  Existing root folders (docs/, rules/, prompts/, scripts/) were not modified."
