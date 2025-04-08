#!/usr/bin/env bash
set -euo pipefail

directory="$1"

# TODO: SVGs are only generated at build time. Can we check for
# a matching .dot file?

# Exclude links to generated files, as these are not available during checks
lychee "$directory" --offline --exclude "$directory/docs/generated/" --exclude '\.svg$'
