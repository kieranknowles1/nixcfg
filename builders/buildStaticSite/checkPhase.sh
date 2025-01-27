#!/usr/bin/env bash
set -euo pipefail
# Silence Nix warnings
# shellcheck disable=SC2269
out="$out"

fails=0
while IFS= read -r -d "" file; do
  echo "Checking $file"
  if ! tidy -quiet > /dev/null "$file"; then
    echo "$file failed to validate"
    fails=$(( fails + 1))
  fi
done < <(find -L "$out" -type f -path '*.html' -print0)

if [[ "$fails" -ne 0 ]]; then
  echo "$fails files failed to validate" >&2
  exit 1
fi
