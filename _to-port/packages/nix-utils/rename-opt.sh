#!/usr/bin/env bash
set -euo pipefail

# Usage: `rename-opt <old> <new>`
# Rename all references to the old option with the new one
# Can only handle simple cases where the full path is given in .nix files,
# e.g., config.long-path.option works, but cfg.option does not.

# Escape '.' so it's treated as a literal character
oldname="${1//./\\.}"
newname="$2"

find . -name '*.nix' -exec sed -i "s|$oldname|$newname|g" {} \;
