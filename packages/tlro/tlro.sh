#!/usr/bin/env bash
set -euo pipefail

# TODO: Properly implement the specification
# TODO: Carapace completions

if [[ "$#" -eq 0 || "$1" == "-h" || "$1" == "--help" ]]; then
  cat <<EOF
Offline-only TLDR client

Usage:
  $0 <page>
EOF
  exit
fi

# All arguments, separated by and with spaces replaced by `-`
IFS='-' page="${*// /-}"
path="$PAGES/$page.md"

if [[ ! -f "$path" ]]; then
  echo "Page '$page' not found." >&2
  exit 1
fi

mdcat "$PAGES/$page.md"
