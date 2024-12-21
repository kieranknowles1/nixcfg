#!/usr/bin/env bash
set -euo pipefail

# Avoid passing an empty argument if no arguments are given
if [ "$#" -lt 2 ]; then
  args=()
else
  args=(-- "${@:2}")
fi

exec nix run ".#$1" "${args[@]}"
