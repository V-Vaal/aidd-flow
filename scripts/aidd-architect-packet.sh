#!/bin/bash

# AIDD Architect Packet: Generate concise validation packet for architect review
# Compiles key excerpts from TARGET.md, github-signals.md, AUDIT.md, INTAKE.md, PLAN.md
# Run from repository root: bash scripts/aidd-architect-packet.sh
#
# Usage:
#   aidd-architect-packet.sh

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Resolve work directory relative to script location
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
WORK_DIR="$REPO_ROOT/aidd/work"

OUTPUT_FILE="$WORK_DIR/ARCHITECT_PACKET.md"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Generating Architect Packet ===${NC}"

# Function to extract section from markdown file
# Usage: extract_section <file> <section_header>
extract_section() {
    local file="$1"
    local section="$2"
    
    if [ ! -f "$file" ]; then
        return 1
    fi
    
    # Extract section content (from header to next ## header or end of file)
    awk -v section="$section" '
        BEGIN { in_section = 0; found = 0 }
        /^## / {
            if (in_section) { exit }
            if ($0 ~ section) { in_section = 1; found = 1; next }
        }
        in_section { print }
        END { exit (found ? 0 : 1) }
    ' "$file" 2>/dev/null || return 1
}

# Function to extract simple file content (for small files like TARGET.md)
extract_file() {
    local file="$1"
    if [ -f "$file" ]; then
        cat "$file"
        return 0
    fi
    return 1
}

# Start building packet
{
    echo "# Architect Validation Packet"
    echo ""
    echo "**Generated:** $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
    echo ""
    echo "This packet contains concise excerpts from AIDD workflow artifacts for architect validation."
    echo ""
    echo "---"
    echo ""

    # 1. TARGET.md (if exists)
    TARGET_FILE="$WORK_DIR/TARGET.md"
    if [ -f "$TARGET_FILE" ]; then
        echo "## Target"
        echo ""
        echo "**Source:** \`aidd/work/TARGET.md\`"
        echo ""
        extract_file "$TARGET_FILE"
        echo ""
        echo "---"
        echo ""
    else
        echo "## Target"
        echo ""
        echo "*TARGET.md not found*"
        echo ""
        echo "---"
        echo ""
    fi

    # 2. GitHub Signals (if exists)
    GITHUB_SIGNALS_FILE="$WORK_DIR/github-signals.md"
    if [ -f "$GITHUB_SIGNALS_FILE" ]; then
        echo "## GitHub Signals"
        echo ""
        echo "**Source:** \`aidd/work/github-signals.md\`"
        echo ""
        # Extract header, query params, and results summary only (facts-only)
        awk '
            BEGIN { in_query = 0; in_summary = 0; done = 0 }
            /^# GitHub Signals/ { print; next }
            /^## Query Parameters/ { in_query = 1; print; next }
            in_query {
                print
                if (/^## Results Summary/) { in_query = 0; in_summary = 1; print; next }
                if (/^## / && !/^## Query Parameters/) { in_query = 0 }
            }
            in_summary {
                print
                if (/^## / && !/^## Results Summary/) { done = 1; exit }
            }
            !done && !in_query && !in_summary && /^## / { exit }
        ' "$GITHUB_SIGNALS_FILE" 2>/dev/null || head -40 "$GITHUB_SIGNALS_FILE"
        echo ""
        echo "*[Full content: \`aidd/work/github-signals.md\`]*"
        echo ""
        echo "---"
        echo ""
    else
        echo "## GitHub Signals"
        echo ""
        echo "*github-signals.md not found*"
        echo ""
        echo "---"
        echo ""
    fi

    # 3. AUDIT.md - Key sections
    AUDIT_FILE="$WORK_DIR/AUDIT.md"
    if [ -f "$AUDIT_FILE" ]; then
        echo "## Audit (Key Sections)"
        echo ""
        echo "**Source:** \`aidd/work/AUDIT.md\`"
        echo ""
        
        # Extract Repo Overview
        if extract_section "$AUDIT_FILE" "## Repo Overview" > /dev/null 2>&1; then
            echo "### Repo Overview"
            extract_section "$AUDIT_FILE" "## Repo Overview" | head -20
            echo ""
        fi
        
        # Extract Open Questions
        if extract_section "$AUDIT_FILE" "## Open Questions" > /dev/null 2>&1; then
            echo "### Open Questions"
            extract_section "$AUDIT_FILE" "## Open Questions" | head -30
            echo ""
        fi
        
        # Extract Action Candidates (if exists)
        if extract_section "$AUDIT_FILE" "## Action Candidates" > /dev/null 2>&1; then
            echo "### Action Candidates"
            extract_section "$AUDIT_FILE" "## Action Candidates" | head -20
            echo ""
        fi
        
        echo "*[Full content: \`aidd/work/AUDIT.md\`]*"
        echo ""
        echo "---"
        echo ""
    else
        echo "## Audit"
        echo ""
        echo "*AUDIT.md not found*"
        echo ""
        echo "---"
        echo ""
    fi

    # 4. INTAKE.md - Scope and Evidence Requirements
    INTAKE_FILE="$WORK_DIR/INTAKE.md"
    if [ -f "$INTAKE_FILE" ]; then
        echo "## Intake (Scope & Evidence)"
        echo ""
        echo "**Source:** \`aidd/work/INTAKE.md\`"
        echo ""
        
        # Extract Goal
        if extract_section "$INTAKE_FILE" "## Goal" > /dev/null 2>&1; then
            echo "### Goal"
            extract_section "$INTAKE_FILE" "## Goal" | head -10
            echo ""
        fi
        
        # Extract Scope
        if extract_section "$INTAKE_FILE" "## Scope" > /dev/null 2>&1; then
            echo "### Scope"
            extract_section "$INTAKE_FILE" "## Scope" | head -25
            echo ""
        fi
        
        # Extract Evidence Requirements
        if extract_section "$INTAKE_FILE" "## Evidence Requirements" > /dev/null 2>&1; then
            echo "### Evidence Requirements"
            extract_section "$INTAKE_FILE" "## Evidence Requirements" | head -15
            echo ""
        fi
        
        echo "*[Full content: \`aidd/work/INTAKE.md\`]*"
        echo ""
        echo "---"
        echo ""
    else
        echo "## Intake"
        echo ""
        echo "*INTAKE.md not found*"
        echo ""
        echo "---"
        echo ""
    fi

    # 5. PLAN.md - High-level steps
    PLAN_FILE="$WORK_DIR/PLAN.md"
    if [ -f "$PLAN_FILE" ]; then
        echo "## Plan (High-Level)"
        echo ""
        echo "**Source:** \`aidd/work/PLAN.md\`"
        echo ""
        
        # Extract Goal
        if extract_section "$PLAN_FILE" "## Goal" > /dev/null 2>&1; then
            echo "### Goal"
            extract_section "$PLAN_FILE" "## Goal" | head -5
            echo ""
        fi
        
        # Extract Scope
        if extract_section "$PLAN_FILE" "## Scope" > /dev/null 2>&1; then
            echo "### Scope"
            extract_section "$PLAN_FILE" "## Scope" | head -15
            echo ""
        fi
        
        # Extract Files to touch
        if extract_section "$PLAN_FILE" "## Files to touch" > /dev/null 2>&1; then
            echo "### Files to touch"
            extract_section "$PLAN_FILE" "## Files to touch" | head -20
            echo ""
        fi
        
        # Extract Steps (high-level, limit to first 10 steps)
        if extract_section "$PLAN_FILE" "## Steps" > /dev/null 2>&1; then
            echo "### Steps (High-Level)"
            extract_section "$PLAN_FILE" "## Steps" | head -25
            echo ""
        fi
        
        echo "*[Full content: \`aidd/work/PLAN.md\`]*"
        echo ""
        echo "---"
        echo ""
    else
        echo "## Plan"
        echo ""
        echo "*PLAN.md not found*"
        echo ""
        echo "---"
        echo ""
    fi

    # Footer
    echo ""
    echo "## Next Steps"
    echo ""
    echo "- Review each section above"
    echo "- Validate scope alignment between INTAKE and PLAN"
    echo "- Verify evidence requirements are met"
    echo "- Check open questions from AUDIT"
    echo "- Approve or request changes"
    echo ""
    echo "*This packet is generated automatically. For full details, refer to source files in \`aidd/work/\`*"

} > "$OUTPUT_FILE"

echo -e "${GREEN}✓ Architect packet generated: ${OUTPUT_FILE}${NC}"
echo ""
echo "Packet includes excerpts from:"
[ -f "$WORK_DIR/TARGET.md" ] && echo "  ✓ TARGET.md"
[ -f "$WORK_DIR/github-signals.md" ] && echo "  ✓ github-signals.md"
[ -f "$WORK_DIR/AUDIT.md" ] && echo "  ✓ AUDIT.md"
[ -f "$WORK_DIR/INTAKE.md" ] && echo "  ✓ INTAKE.md"
[ -f "$WORK_DIR/PLAN.md" ] && echo "  ✓ PLAN.md"
echo ""
