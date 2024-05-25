#!/usr/bin/env bash

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

# Use the current directory and imply the config to use from the system's hostname
sudo nixos-rebuild switch --flake .

# Header and current generation
generation_meta=$(nixos-rebuild list-generations | head -n 2)

# Generation number
generation_number=$(echo "$generation_meta" | tail -n 1 | awk '{print $1}')
host=$(hostname)

git add .
git commit -m "$host#$generation_number: $commit_message" -m "$generation_meta"
