#!/usr/bin/env bash

# TODO: Use writeShellScriptBin to generate this and remove nh/nvd from modules/nixos/core.nix

# Rebuilds the system from the current repository state and commits the changes
# if successful. The commit message includes the generation number and the
# provided description.

set -e

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <commit message>" >&2
  exit 1
fi

if [ "$EUID" -eq 0 ]; then
echo "Do not run this script as root" >&2
  exit 1
fi

commit_message="$1"

# Build the system, but don't switch to it yet
# Use the hostname as a key in nixosConfigurations
# The build step doesn't apply anything, but gives us a diff to the current system
nh os build .

# Get a diff of the current configuration for in the commit message
# Must be done between build and activation, otherwise we'll just be comparing current with current
nixos-rebuild build --flake .
diff=$(nvd diff /run/current-system result/)

# Apply the new configuration
sudo nixos-rebuild switch --flake .

# Header and current generation
generation_meta=$(nixos-rebuild list-generations | head -n 2)

# Generation number
generation_number=$(echo "$generation_meta" | tail -n 1 | awk '{print $1}')
host=$(hostname)

git add .
git commit \
  -m "$host#$generation_number: $commit_message" \
  -m "$generation_meta" \
  -m "$diff"
