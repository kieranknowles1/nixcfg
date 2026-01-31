#!/usr/bin/env bash
set -euo pipefail

directory="$1"

# Exclude links to generated files, as these are not available during checks
# Remap .svg to .dot, as SVGs are generated from them at build time
lychee "$directory" --offline --exclude "$directory/docs/generated/" --remap '.svg .dot'
