#!/usr/bin/env bash
set -euo pipefail

directory="${1:-.}"
# Print help message
if [[ "$directory" == "-h" || "$directory" == "--help" ]]; then
  cat <<EOF
Usage: $0 [directory=\$PWD]
  Display all TODO comments in the specified directory.
  If no directory is specified, the current working
  directory is used.

  A TODO comment is defined as a line that contains
  a comment starting sequence such as '//' and a
  TODO tag such as 'TODO'

  Results are sorted by last modified time, showing
  the most recently modified files at the bottom.
  Gitignored files are not included in the results.
EOF
  exit 0
fi


COMMENT_STARTS=(
  '#' # Bash
  '//' # C
  '/\*' # C
  '--' # Lua
  '<!--' # HTML
  '-' # Markdown list
  '%' # Tex
)

TODO_TAGS=(
  'TODO'
  'FIXME'
  'HACK'
  '\[ \]' # Markdown task list
)

# Regex to match any of the provided strings
any_of() {
  local IFS='|'
  echo "($*)"
}

ANY_COMMENT=$(any_of "${COMMENT_STARTS[@]}")
query="$ANY_COMMENT.*$(any_of "${TODO_TAGS[@]}")"

rg "$query" "$directory" --sort modified --context 2

echo "Summary:"
total=0
for tag in "${TODO_TAGS[@]}"; do
  plainTag=$(sed 's|\\||g' <<< $tag)
  count=$((rg "$ANY_COMMENT.*$tag" "$directory" "$@" || true) | wc -l)
  total=$((total + count))

  if [[ $count -gt 0 ]]; then
    echo "  $count ${plainTag}s"
  fi
done
echo "  $total total tasks"
