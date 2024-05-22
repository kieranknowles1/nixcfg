#!/usr/bin/env bash

set -e

if [ "$EUID" -eq 0 ]; then
  echo "Do not run this script as root" >&2
  exit 1
fi

# TODO: Git commit on success. Include generation number

sudo nixos-rebuild switch --flake .#desktop
