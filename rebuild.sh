#!/usr/bin/env bash

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

sudo nixos-rebuild switch --flake .#desktop

# Header and current generation
generation_meta=$(nixos-rebuild list-generations | head -n 2)

# Generation number
generation_number=$(echo "$generation_meta" | tail -n 1 | awk '{print $1}')

git add .
git commit -m "$generation_number: $commit_message" -m "$generation_meta"