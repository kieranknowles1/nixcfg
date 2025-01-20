#!/usr/bin/env bash
set -euo pipefail

error() {
  echo "Error: $1" >&2
  exit 1
}

if [ "$#" -ne 2 ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
  echo "Usage: $0 [home|nixos] <option_path>"
  if [ "$#" -ne 0 ] && [ "$1" != "-h" ] && [ "$1" != "--help" ]; then
    exit 1
  else
    exit 0
  fi
fi

# Coreutils-like behavior of switching behavior based on script name
# Only have one copy in Git as they are symlinked together
if [[ "$0" =~ "confbuild" ]]; then
  action="build"
elif [[ "$0" =~ "confeval" ]]; then
  action="eval"
else
  error "Could not determine action from script name: $0"
fi
mode="$1"
option_path="$2"

prefix=".#nixosConfigurations.$(hostname).config"

if [ "$mode" == "home" ] || [ "$mode" == "h" ]; then
  prefix="$prefix.home-manager.users.$USER.custom"
elif [ "$mode" == "nixos" ] || [ "$mode" == "n" ]; then
  prefix="$prefix.custom"
else
  error "Mode could not be determined from script name: $0"
fi

full_path="$prefix.$option_path"

if [ "$action" == "build" ] || [ "$action" == "b" ]; then
  nix build "$full_path"
elif [ "$action" == "eval" ] || [ "$action" == "e" ]; then
  nix eval "path:$full_path" --json
else
  error "Invalid action: $action"
fi
