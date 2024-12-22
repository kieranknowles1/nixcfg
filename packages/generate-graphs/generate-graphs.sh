#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 [directory=.]
  --help, -h  Display this help message and exit
  --check, -c Do not modify files, exit 1 if any would have been modified
EOF
}

dir=.
check=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    -c|--check)
      check=true
      ;;
    *)
      dir="$1"
      ;;
  esac
  shift
done

if [ "$check" = true ]; then
  echo "Checking all graphs are up to date"
else
  echo "Generating graphs"
fi

tmp_file=$(mktemp)
any_fail=false
while read -r -d '' file; do
  echo "Processing $file"
  svg_name="${file%.dot}.svg"

  dot -Tsvg "$file" -o "$tmp_file"
  if [ "$check" = true ]; then
    cmp -s "$tmp_file" "$svg_name" || {
      echo "File $svg_name is missing or out of date" >&2
      any_fail=true
    }
  else
    mv "$tmp_file" "$svg_name"
  fi
done < <(find "$dir" -name '*.dot' -print0)

if [ -f "$tmp_file" ]; then
  rm "$tmp_file"
fi

if [ "$any_fail" = true ]; then
  echo "One or more files are out of date" >&2
  exit 1
fi
