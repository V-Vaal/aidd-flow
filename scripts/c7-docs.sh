#!/usr/bin/env bash
# c7-docs.sh — Context7 docs via public REST API
# Usage: c7-docs.sh --library <library-id> [--topic <topic>] [--tokens <n>]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AIDD_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
if [ "$(basename "$AIDD_ROOT")" = ".aidd-flow" ]; then
  PROJECT_ROOT="$(cd "$AIDD_ROOT/.." && pwd)"
else
  PROJECT_ROOT="$AIDD_ROOT"
fi

WORK_DIR="$AIDD_ROOT/aidd/work"
SUMMARY_FILE="$WORK_DIR/SUMMARY.md"
CACHE_DIR="$AIDD_ROOT/cache/context7"
CACHE_TTL_SECONDS="${C7_CACHE_TTL_SECONDS:-86400}"

LIBRARY=""
TOPIC=""
TOKENS="2000"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --library) LIBRARY="$2"; shift 2 ;;
    --topic)   TOPIC="$2"; shift 2 ;;
    --tokens)  TOKENS="$2"; shift 2 ;;
    *)
      echo "Unknown option: $1" >&2
      echo "Usage: c7-docs.sh --library <library-id> [--topic <topic>] [--tokens <n>]" >&2
      exit 1
      ;;
  esac
done

if [ -z "$LIBRARY" ]; then
  cat >&2 <<'USAGE'
Usage: c7-docs.sh --library <library-id> [--topic <topic>] [--tokens <n>]

Examples:
  c7-docs.sh --library reactjs/react.dev --topic hooks --tokens 2000
  c7-docs.sh --library wevm/wagmi --topic useAccount
  c7-docs.sh --library vercel/next.js --tokens 3000
USAGE
  exit 1
fi

if ! [[ "$TOKENS" =~ ^[0-9]+$ ]]; then
  echo "Error: --tokens must be a positive integer" >&2
  exit 1
fi

mkdir -p "$CACHE_DIR" "$WORK_DIR"

ensure_summary_file() {
  if [ ! -f "$SUMMARY_FILE" ]; then
    cat > "$SUMMARY_FILE" <<'EOF_SUM'
# Summary

## Context Budget

- low

## Context7 Evidence

None yet.

## Phase Snapshots

EOF_SUM
  fi
}

record_context7_evidence() {
  local source="$1"
  local timestamp
  timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  ensure_summary_file

  awk -v line="- ${timestamp} | library=${LIBRARY} | topic=${TOPIC:-none} | tokens=${TOKENS} | source=${source}" '
    BEGIN {in_section=0; inserted=0; had_none=0}
    /^## Context7 Evidence/ {
      print
      in_section=1
      next
    }
    /^## / && in_section {
      if (!inserted) {
        print ""
        print line
        inserted=1
      }
      in_section=0
    }
    {
      if (in_section && $0 == "None yet.") {
        had_none=1
        next
      }
      print
    }
    END {
      if (!inserted) {
        if (NR > 0) print ""
        if (!in_section) {
          print "## Context7 Evidence"
          print ""
        }
        print line
      }
    }
  ' "$SUMMARY_FILE" > "$SUMMARY_FILE.tmp" && mv "$SUMMARY_FILE.tmp" "$SUMMARY_FILE"
}

TOPIC_Q=""
if [ -n "$TOPIC" ]; then
  TOPIC_Q="$(printf '%s' "$TOPIC" | sed 's/ /+/g')"
fi

CACHE_KEY=$(printf '%s|%s|%s' "$LIBRARY" "$TOPIC_Q" "$TOKENS" | cksum | awk '{print $1}')
CACHE_FILE="$CACHE_DIR/${CACHE_KEY}.md"

if [ -f "$CACHE_FILE" ]; then
  now_epoch=$(date +%s)
  file_epoch=$(date -r "$CACHE_FILE" +%s)
  age=$((now_epoch - file_epoch))
  if [ "$age" -le "$CACHE_TTL_SECONDS" ]; then
    record_context7_evidence "cache"
    cat "$CACHE_FILE"
    exit 0
  fi
fi

BASE_URL="https://context7.com/api/v2/docs/code/${LIBRARY}"
QUERY="tokens=${TOKENS}"
if [ -n "$TOPIC_Q" ]; then
  QUERY="${QUERY}&topic=${TOPIC_Q}"
fi
URL="${BASE_URL}?${QUERY}"

RESPONSE=$(curl -sf --max-time 15 "$URL" 2>/dev/null) || {
  EXIT=$?
  if [ $EXIT -eq 22 ]; then
    cat >&2 <<EOF_ERR
Error: unsupported or unknown library-id: "${LIBRARY}"
Check exact ID (example: reactjs/react.dev, wevm/wagmi, vercel/next.js).
EOF_ERR
  else
    echo "Network error (curl exit $EXIT): unable to fetch Context7." >&2
  fi
  exit 1
}

printf '%s' "$RESPONSE" > "$CACHE_FILE"
record_context7_evidence "network"
printf '%s' "$RESPONSE"
