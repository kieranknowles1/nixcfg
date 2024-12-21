#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 2 ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
  echo "Usage: $0 [home|nixos] <option_path>"
  if [ "$1" != "-h" ] && [ "$1" != "--help" ]; then
    exit 1
  else
    exit 0
  fi
fi

mode="$1"
option_path="$2"

prefix=".#nixosConfigurations.$(hostname).config"

if [ "$mode" == "home" ] || [ "$mode" == "h" ]; then
  prefix="$prefix.home-manager.users.$USER.custom"
elif [ "$mode" == "nixos" ] || [ "$mode" == "n" ]; then
  prefix="$prefix.custom"
else
  echo "Invalid mode: $mode"
  exit 1
fi

exec nix build "$prefix.$option_path"
