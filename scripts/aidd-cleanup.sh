#!/bin/bash

# Archive aidd/work/ artifacts older than N days (default: 30)
# Usage: bash scripts/aidd-cleanup.sh [--days N] [--dry-run]
# Run from repository root.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
WORK_DIR="$REPO_ROOT/aidd/work"
ARCHIVE_DIR="$WORK_DIR/_archive"

DAYS=30
DRY_RUN=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --days)
            DAYS="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            echo "Unknown argument: $1"
            echo "Usage: bash scripts/aidd-cleanup.sh [--days N] [--dry-run]"
            exit 1
            ;;
    esac
done

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "aidd-cleanup: scanning $WORK_DIR for artifacts older than $DAYS days..."
if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}DRY RUN — no files will be moved${NC}"
fi

if [ ! -d "$WORK_DIR" ]; then
    echo "No aidd/work/ directory found. Nothing to clean."
    exit 0
fi

# Artifacts eligible for archiving (root-level markdown files)
ARTIFACTS=("AUDIT.md" "INTAKE.md" "PLAN.md" "REVIEW.md" "TARGET.md" "github-signals.md" "github-signals.config.yml" "RUN_STATE.json")

ARCHIVED=0

for artifact in "${ARTIFACTS[@]}"; do
    FILE="$WORK_DIR/$artifact"
    if [ ! -f "$FILE" ]; then
        continue
    fi

    # Check file age (modification time)
    FILE_AGE_DAYS=$(( ( $(date +%s) - $(date -r "$FILE" +%s) ) / 86400 ))

    if [ "$FILE_AGE_DAYS" -ge "$DAYS" ]; then
        TIMESTAMP=$(date +%Y%m%d-%H%M%S)
        DEST="$ARCHIVE_DIR/${TIMESTAMP}-${artifact}"

        if [ "$DRY_RUN" = true ]; then
            echo "  [dry-run] would archive: $artifact (${FILE_AGE_DAYS}d old) → _archive/${TIMESTAMP}-${artifact}"
        else
            mkdir -p "$ARCHIVE_DIR"
            mv "$FILE" "$DEST"
            echo -e "  ${GREEN}archived${NC}: $artifact (${FILE_AGE_DAYS}d old) → _archive/${TIMESTAMP}-${artifact}"
        fi
        ARCHIVED=$((ARCHIVED + 1))
    fi
done

echo ""
if [ "$ARCHIVED" -eq 0 ]; then
    echo "Nothing to archive (no artifacts older than $DAYS days)."
elif [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}Dry run complete: $ARCHIVED artifact(s) would be archived.${NC}"
else
    echo -e "${GREEN}Done: $ARCHIVED artifact(s) archived to aidd/work/_archive/${NC}"
fi
