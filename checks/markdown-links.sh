#!/usr/bin/env bash

set -e
set -o pipefail

cfg_file="$1"
directory="$2"

any_fail=0
while IFS= read -r -d '' file; do
  # Exclude ./docs/generated/ directory
  if [[ "$file" == *"/docs/generated/"* ]]; then
    continue
  fi

  echo "Checking $file"
  markdown-link-check --quiet --config "$cfg_file" "$file" || any_fail=1
done < <(find "$directory" -name "*.md" -print0)

exit "$any_fail"
