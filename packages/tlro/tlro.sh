#!/usr/bin/env bash
set -euo pipefail

showhelp() {
  cat <<EOF
Offline-only TLDR client

Usage: $0 [command]
  -h|--help:
    Show this help message and exit
EOF
  exit
}

positional=()
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      showhelp
      ;;
    -v|--version)
      echo "tlro version $VERSION, client specification 2.3"
      ;;
    -l|--list)
      ls "$PAGES" | sed 's|\.md||'
      exit
      ;;
    -*)
      echo "Unknown flag '$1'" >&2
      exit 1
      ;;
    *)
      positional+=("$1")
      ;;
  esac
  shift
done

if [[ "${positional[@]}" == "" ]]; then
  showhelp
fi

# TODO: Properly implement the specification
# TODO: Carapace completions
# TODO: Add TLDR pages based on meta attributes of my packages, will need restructuring to fit in with the standard
# TODO: Implement short/long form options

# All arguments, separated by and with spaces replaced by `-`
# and lowercased
IFS='-'
page=$(echo "${positional[@]}" | sed 's| |-|' | tr '[:upper:]' '[:lower:]')

if [[ ! -f "$path" ]]; then
  echo "Page '$page' not found." >&2
  exit 1
fi

mdcat "$PAGES/$page.md"
