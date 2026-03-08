#!/usr/bin/env bash
# gh-context.sh — Accès GitHub minimaliste pour agents IA (phase ARCHITECT)
# Usage: gh-context.sh <subcommand> [args]
# Subcommands: issue <NUMBER>, pr <NUMBER>, issues-open, prs-open
set -euo pipefail

CMD="${1:-}"

case "$CMD" in
  issue)
    NUMBER="${2:-}"
    if [ -z "$NUMBER" ]; then
      echo '{"error":"usage: gh-context.sh issue <NUMBER>"}' >&2
      exit 1
    fi
    gh issue view "$NUMBER" \
      --json number,title,body,state,labels \
      --jq '{number:.number,title:.title,state:.state,labels:[.labels[].name],body:.body}'
    ;;

  pr)
    NUMBER="${2:-}"
    if [ -z "$NUMBER" ]; then
      echo '{"error":"usage: gh-context.sh pr <NUMBER>"}' >&2
      exit 1
    fi
    gh pr view "$NUMBER" \
      --json number,title,body,state,mergeable,labels \
      --jq '{number:.number,title:.title,state:.state,mergeable:.mergeable,labels:[.labels[].name],body:.body}'
    ;;

  issues-open)
    gh issue list --state open --limit 10 \
      --json number,title,labels \
      --jq '[.[] | {number:.number,title:.title,labels:[.labels[].name]}]'
    ;;

  prs-open)
    gh pr list --state open --limit 5 \
      --json number,title,state \
      --jq '[.[] | {number:.number,title:.title,state:.state}]'
    ;;

  *)
    cat >&2 <<'EOF'
Usage: gh-context.sh <subcommand> [args]

Subcommands:
  issue <NUMBER>    Titre, body, state, labels d'une issue
  pr <NUMBER>       Titre, body, state, mergeable, labels d'un PR
  issues-open       10 dernières issues ouvertes (numéro, titre, labels)
  prs-open          5 derniers PRs ouverts (numéro, titre, state)

Output: JSON pur, consommable directement par un LLM.
EOF
    exit 1
    ;;
esac
