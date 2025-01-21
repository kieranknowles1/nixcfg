#!/usr/bin/env bash
set -euo pipefail

target="${1:-default}"
if [[ "$target" == "-h" || "$target" == "--help" ]]; then
  cat <<EOF
Usage: $0 [target=default]
  target: Which check to build.

  Attempt to build the requested check. If this fails, then a non-zero
  exit code is returned and build logs are printed.
EOF
  exit 0
fi

system="$(nix eval --impure --raw --expr 'builtins.currentSystem')"
exec nix build ".#checks.$system.$target" --no-link --print-build-logs
