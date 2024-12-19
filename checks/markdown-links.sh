#!/usr/bin/env bash
set -euo pipefail

cfg_file="$1"
directory="$2"

# All markdown files
readarray -d '' files < <(find "$directory" -name "*.md" -print0)

# Only print file names and failed links
markdown-link-check --quiet --config "$cfg_file" "${files[@]}"
