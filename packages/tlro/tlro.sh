#!/usr/bin/env bash
set -euo pipefail

# May be set by Nix
SHORTOPTS=${SHORTOPTS:-0}
LONGOPTS=${LONGOPTS:-0}

showhelp() {
  shortOptDefault=$([[ $SHORTOPTS == 1 ]] && echo " (default)" || echo "")
  longOptDefault=$([[ $LONGOPTS == 1 ]] && echo " (default)" || echo "")

  cat <<EOF
Offline-only TLDR client

Usage: $0 [command]
  -h|--help:
    Show this help message and exit
  -v|--version:
    Show the version number and eixt
  -l|--list
    List all the pages to the standard output.
    If a command is provided, filter pages based on it.
  --short-options:
    Show short-form options if available$shortOptDefault
  --long-options:
    Show long-form options if available$longOptDefault

  If both '--short-options' and '--long-options' are passed, then
  both will be shown.
EOF
  exit
}

# Short/long-form arguments in the form {{[short|long]}}
SED_ARGUMENT_PATTERN='\{\{\[([a-zA-Z -]+)\|([a-zA-Z -]+)\]\}\}'

query=""
list=0
shortopts=0
longopts=0
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      showhelp
      ;;
    -v|--version)
      echo "tlro version $VERSION, client specification 2.3"
      exit
      ;;
    -l|--list)
      list=1
      ;;
    --short-options)
      shortopts=1
      arg_replace='\1'
      ;;
    --long-options)
      longopts=1
      arg_replace='\2'
      ;;
    -*)
      echo "Unknown flag '$1'" >&2
      exit 1
      ;;
    *)
      query="$query-${1// /-}"
      ;;
  esac
  shift
done
# Remove leading dashes from when we appended
query="${query#-}"

if [[ "$query" == "" ]]; then
  showhelp
fi

if [[ "$list" == 1 ]]; then
  # The information here is intended for the user
  # shellcheck disable=SC2012
  ls "$PAGES" | sed 's|\.md||' | grep --color "$query"
  exit
fi

if [[ "$shortopts" == 0 && "$longopts" == 0 ]]; then
  shortopts=$SHORTOPTS
  longopts=$LONGOPTS
fi

if [[ "$shortopts" == 1 && "$longopts" == 1 ]]; then
  arg_replace='[\1|\2]' # Show both, surrounded by [] and separated by a pipe
elif [[ "$shortopts" == 1 ]]; then
  arg_replace='\1'
else
  arg_replace='\2'
fi

# TODO: Carapace completions
# TODO: Add TLDR pages based on meta attributes of my packages, will need restructuring to fit in with the standard

# All arguments, separated by and with spaces replaced by `-`
# and lowercased
IFS='-'
path="$PAGES/$query.md"

if [[ ! -f "$path" ]]; then
  echo "Page '$query' not found." >&2
  exit 1
fi

# Reformat things a bit
# 1. Only show short/long-form versions of arguments accodring to $LONGOPTS
# 2. Replace example code blocks with bold (we're on the terminal, so assume a monospaced font)
# 3. Show editable placeholders as code blocks (mdcat uses orange for these)
# $ is being used as part of the sed expression, not for variable expansion
# shellcheck disable=SC2016
sed --regexp-extended "s/$SED_ARGUMENT_PATTERN/$arg_replace/" "$path" \
  | sed --regexp-extended 's|^`(.+)`$|**\1**|' \
  | perl -pe 's|\{\{(.+?)\}\}|`\1`|g' \
  | mdcat
