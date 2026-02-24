#!/bin/bash

# AIDD Finish: guided post-review closeout
# Usage: bash scripts/aidd-finish.sh
# Run from repository root.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
WORK_DIR="$REPO_ROOT/aidd/work"
REVIEW_FILE="$WORK_DIR/REVIEW.md"
ACTIVE_CONTEXT="$REPO_ROOT/aidd/memory/activeContext.md"
CLEANUP_SCRIPT="$SCRIPT_DIR/aidd-cleanup.sh"

confirm() {
    local prompt="$1"
    local default="${2:-N}"
    local reply

    if [ "$default" = "Y" ]; then
        read -r -p "$prompt [Y/n]: " reply
        reply=${reply:-Y}
    else
        read -r -p "$prompt [y/N]: " reply
        reply=${reply:-N}
    fi

    case "$reply" in
        [Yy]*) return 0 ;;
        *) return 1 ;;
    esac
}

get_verdict() {
    local verdict_section verdict_line verdict_value
    verdict_section=$(grep -A 5 "^## Verdict" "$REVIEW_FILE" 2>/dev/null || true)
    verdict_line=$(echo "$verdict_section" | grep -iE "^\*\*Verdict\*\*|^Verdict" | head -1 || true)

    if [ -z "$verdict_line" ]; then
        echo ""
        return 0
    fi

    verdict_value=$(echo "$verdict_line" | sed -E 's/.*[Vv]erdict[:\*]*[[:space:]]*//' | tr -d '[]' | tr '[:lower:]' '[:upper:]' | xargs)
    echo "$verdict_value"
}

suggest_commit_message() {
    if ! command -v git &> /dev/null || [ ! -d "$REPO_ROOT/.git" ]; then
        echo "chore: update workflow artifacts"
        return 0
    fi

    local files has_docs has_scripts has_rules has_prompts has_finish
    files=$(git -C "$REPO_ROOT" diff --name-only)
    if [ -z "$files" ]; then
        files=$(git -C "$REPO_ROOT" diff --cached --name-only)
    fi

    has_docs=0
    has_scripts=0
    has_rules=0
    has_prompts=0
    has_finish=0

    for file in $files; do
        case "$file" in
            docs/*|README.md|README.fr.md)
                has_docs=1
                ;;
            scripts/*)
                has_scripts=1
                ;;
            rules/*)
                has_rules=1
                ;;
            prompts/*)
                has_prompts=1
                ;;
        esac

        if [ "$file" = "scripts/aidd-finish.sh" ]; then
            has_finish=1
        fi
    done

    if [ "$has_finish" -eq 1 ]; then
        echo "chore: add aidd finish helper script"
        return 0
    fi

    if [ "$has_docs" -eq 1 ] && [ "$has_scripts" -eq 0 ] && [ "$has_rules" -eq 0 ] && [ "$has_prompts" -eq 0 ]; then
        echo "docs: update workflow documentation"
        return 0
    fi

    echo "chore: update workflow tooling"
}

print_review_summary() {
    if [ ! -f "$REVIEW_FILE" ]; then
        return 0
    fi

    echo "Review summary:"
    awk '
        /^## Summary of changes/ {flag=1; next}
        /^## / {flag=0}
        flag {print}
    ' "$REVIEW_FILE" | head -n 6
    echo ""
}

build_pr_body() {
    local summary
    summary=$(awk '
        /^## Summary of changes/ {flag=1; next}
        /^## / {flag=0}
        flag {print}
    ' "$REVIEW_FILE" | head -n 8)

    if [ -z "$summary" ]; then
        summary="- See aidd/work/REVIEW.md"
    fi

    cat <<EOF
## Summary
$summary

## Testing
- bash scripts/aidd-check.sh

## Review
- Verdict: APPROVE
EOF
}

print_pr_instructions() {
    local title="$1"
    local body
    body="$(build_pr_body)"

    echo "PR command (manual):"
    echo "gh pr create --title \"$title\" --body \"$(echo "$body" | tr '\n' ' ')\""
    echo ""
    echo "Suggested PR body:"
    echo "$body"
}

update_active_context() {
    if [ ! -f "$ACTIVE_CONTEXT" ]; then
        echo "activeContext.md not found: $ACTIVE_CONTEXT"
        return 1
    fi

    local timestamp note has_note tmp_file
    timestamp=$(date -u "+%Y-%m-%dT%H:%M:%SZ")
    note="- Completed finish flow after APPROVE review."
    has_note=0

    if grep -qF "$note" "$ACTIVE_CONTEXT"; then
        has_note=1
    fi

    tmp_file="${ACTIVE_CONTEXT}.tmp"
    awk -v ts="$timestamp" -v note="$note" -v has_note="$has_note" '
        /^## Last Updated/ {print; getline; print ts; next}
        /^## Recently Completed/ {
            print
            if (has_note == 0) {
                print note
            }
            next
        }
        {print}
    ' "$ACTIVE_CONTEXT" > "$tmp_file"

    mv "$tmp_file" "$ACTIVE_CONTEXT"
    echo "Updated $ACTIVE_CONTEXT"
}

purge_work_artifacts() {
    local artifacts file
    artifacts=("AUDIT.md" "INTAKE.md" "PLAN.md" "REVIEW.md" "TARGET.md" "github-signals.md" "github-signals.config.yml" "RUN_STATE.json")

    for artifact in "${artifacts[@]}"; do
        file="$WORK_DIR/$artifact"
        if [ -f "$file" ]; then
            rm -f "$file"
            echo "Removed $artifact"
        fi
    done
}

create_intake_from_followups() {
    local followups
    followups=$(awk '
        /^## Follow-ups/ {flag=1; next}
        /^## / {flag=0}
        flag {print}
    ' "$REVIEW_FILE" | sed '/^[[:space:]]*$/d')

    if [ -z "$followups" ]; then
        followups="- No follow-ups extracted. Define scope and goals manually."
    fi

    cat <<EOF > "$WORK_DIR/INTAKE.md"
# Intake

**Artefact Status**: DRAFT
**Change Class**: C (follow-up iteration)

## How to use

Seeded from the previous review follow-ups. Refine goal, scope, and risks before planning.

## Goal

Define the next task based on the latest review follow-ups.

## Scope

### In Scope

$followups

### Out-of-scope

- Items not listed above.

## Risks

- Risks to be identified and documented during intake refinement.

## Evidence Requirements

- `bash scripts/aidd-check.sh` after implementation.

## Definition of Done

- INTAKE and PLAN reviewed and validated.
- REVIEW verdict is APPROVE.
EOF

    echo "Created $WORK_DIR/INTAKE.md"
}

echo "=== AIDD Finish ==="

if [ ! -f "$REVIEW_FILE" ]; then
    echo "Error: REVIEW.md not found at $REVIEW_FILE"
    exit 1
fi

verdict=$(get_verdict)
if [ -z "$verdict" ]; then
    echo "Error: Verdict not found in REVIEW.md"
    exit 1
fi

if [ "$verdict" != "APPROVE" ]; then
    echo "Review verdict is $verdict. Finish flow requires APPROVE."
    exit 1
fi

echo "Review verdict: APPROVE"
print_review_summary

git_available=0
if command -v git &> /dev/null && [ -d "$REPO_ROOT/.git" ]; then
    git_available=1
    echo "Git status:"
    git -C "$REPO_ROOT" status -sb
    echo ""
    echo "Git diff summary:"
    git -C "$REPO_ROOT" diff --stat
    echo ""
else
    echo "Git not available or repo not detected. Skipping git steps."
fi

commit_message="$(suggest_commit_message)"
echo "Suggested commit message: $commit_message"

if confirm "Use suggested commit message?" "Y"; then
    :
else
    read -r -p "Enter commit message: " commit_message
fi

if [ "$git_available" -eq 1 ]; then
    if confirm "Stage all changes with git add -A?" "N"; then
        git -C "$REPO_ROOT" add -A
    fi

    if confirm "Create commit now?" "N"; then
        if [ -z "$(git -C "$REPO_ROOT" diff --cached --name-only)" ]; then
            echo "No staged changes to commit."
        else
            git -C "$REPO_ROOT" commit -m "$commit_message"
        fi
    fi

    if confirm "Push to remote?" "N"; then
        if git -C "$REPO_ROOT" rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
            git -C "$REPO_ROOT" push
        else
            branch=$(git -C "$REPO_ROOT" branch --show-current)
            echo "No upstream configured. Suggested command:"
            echo "  git push -u origin $branch"
        fi
    fi

    if confirm "Create a PR?" "N"; then
        if command -v gh &> /dev/null; then
            if confirm "Create PR via gh now?" "Y"; then
                pr_body=$(build_pr_body)
                (cd "$REPO_ROOT" && gh pr create --title "$commit_message" --body "$pr_body")
            else
                print_pr_instructions "$commit_message"
            fi
        else
            echo "gh is not installed. Example command:"
            print_pr_instructions "$commit_message"
        fi
    fi
fi

if confirm "Update aidd/memory/activeContext.md?" "Y"; then
    update_active_context
fi

echo ""
echo "Cleanup options:"
echo "  1) Archive old artifacts using scripts/aidd-cleanup.sh (default >30 days)."
echo "  2) Purge current artifacts from aidd/work (removes known work files)."
echo "  3) Skip cleanup."
read -r -p "Choose [1/2/3] (default 3): " cleanup_choice
cleanup_choice=${cleanup_choice:-3}

case "$cleanup_choice" in
    1)
        if [ -f "$CLEANUP_SCRIPT" ]; then
            if confirm "Run cleanup in dry-run mode first?" "Y"; then
                bash "$CLEANUP_SCRIPT" --dry-run
            fi
            if confirm "Proceed with cleanup?" "Y"; then
                bash "$CLEANUP_SCRIPT"
            fi
        else
            echo "Cleanup script not found: $CLEANUP_SCRIPT"
        fi
        ;;
    2)
        echo "This will remove current work artifacts from $WORK_DIR."
        if confirm "Proceed with purge?" "N"; then
            purge_work_artifacts
        fi
        ;;
    *)
        echo "Cleanup skipped."
        ;;
esac

if confirm "Start a new INTAKE from review follow-ups?" "N"; then
    if confirm "This will overwrite $WORK_DIR/INTAKE.md. Continue?" "N"; then
        create_intake_from_followups
    fi
fi

echo ""
echo "Finish flow complete."
