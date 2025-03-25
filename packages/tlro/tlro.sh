#!/usr/bin/env bash
set -euo pipefail

showhelp() {
  shortOptDefault=$([[ $LONGOPTS == 1 ]] && echo " (default)" || echo "")
  longOptDefault=$([[ $LONGOPTS == 2 ]] && echo " (default)" || echo "")

  cat <<EOF
Offline-only TLDR client

Usage: $0 [command]
  -h|--help:
    Show this help message and exit
  -v|--version:
    Show the version number and eixt
  -l|--list:
    List all the pages to the standard output
  --short-options:
    Show short-form options if available$shortOptDefault
  --long-options:
    Show long-form options if available$longOptDefault
EOF
  exit
}

# Short/long-form arguments in the form {{[short|long]}}
SED_ARGUMENT_PATTERN='\{\{\[([a-zA-Z -]+)\|([a-zA-Z -]+)\]\}\}'
arg_replace="\\$LONGOPTS"
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
      # The information here is intended for the user
      # shellcheck disable=SC2012
      ls "$PAGES" | sed 's|\.md||'
      exit
      ;;
    --short-options)
      arg_replace='\1'
      ;;
    --long-options)
      arg_replace='\2'
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

if [[ "${positional[*]}" == "" ]]; then
  showhelp
fi

# TODO: Properly implement the specification
# TODO: Carapace completions
# TODO: Add TLDR pages based on meta attributes of my packages, will need restructuring to fit in with the standard

# All arguments, separated by and with spaces replaced by `-`
# and lowercased
IFS='-'
page=$(echo "${positional[@]}" | sed 's| |-|' | tr '[:upper:]' '[:lower:]')
path="$PAGES/$page.md"

if [[ ! -f "$path" ]]; then
  echo "Page '$page' not found." >&2
  exit 1
fi

sed --regexp-extended "s/$SED_ARGUMENT_PATTERN/$arg_replace/" "$path" | mdcat
