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
  'TODO' # Generic task to perform
  'FIXME' # Something is broken
  'HACK' # Ugly code that should be refactored
  'LOOK' # Someting to do more research on
  '\[ \]' # Markdown task list
  'WTF' # What the fuck? Why did it break when an unrelated change was made?
)

STANDALONE_TAGS=(
  '\\todo\{' # Tex
)

# Regex to match any of the provided strings
any_of() {
  local IFS='|'
  echo "($*)"
}

ANY_COMMENT=$(any_of "${COMMENT_STARTS[@]}")
COMMENT_AND_TODO="$ANY_COMMENT\s*$(any_of "${TODO_TAGS[@]}")"
query="($COMMENT_AND_TODO|$(any_of "${STANDALONE_TAGS[@]}"))"

search() {
  rg "$query" "$directory" "$@"
}

search --sort modified --context 2

echo "Summary:"
for tag in "${TODO_TAGS[@]}"; do
  plainTag=${tag//\\/}
  count=$( (rg "$ANY_COMMENT.*$tag" "$directory" || true) | wc -l)

  if [[ $count -gt 0 ]]; then
    echo "  $count ${plainTag}s"
  fi
done
echo "  $(search | wc -l) total tasks"
