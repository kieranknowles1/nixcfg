#!/usr/bin/env bash
set -euo pipefail

# Check that all symlinks are valid, i.e., they point to existing files o
# directories

error=0
while IFS= read -r -d '' file; do
  if ! [[ -e "$file" ]]; then
    echo "Error: Symlink $file points to non-existent file"
    error=1
  fi
done < <(find "$1" -type l -print0)

if [[ $error -ne 0 ]]; then
  echo "Error: Found invalid symlinks"
  exit 1
fi
