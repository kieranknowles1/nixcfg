#!/usr/bin/env bash
set -euo pipefail

cfg_file="$1"
directory="$2"

# All markdown files
readarray -d '' files < <(find "$directory" -name "*.md" -print0)

# Only print file names and failed links
# TODO: Internal links currently fail and need to be ignored.
# Can markdown-link-check detect these?
# TODO: SVGs are only generated at build time. Can we check for
# a matching .dot file?
markdown-link-check --quiet --config "$cfg_file" "${files[@]}"
