#!/usr/bin/env bash
set -euo pipefail

lock_file="$1/flake.lock"

# Very simple check for duplicate inputs, Nix names these with _<number>,
# while the convention is to use hyphens. Shouldn't cause false positives unless
# something violates this convention.
dupes=$(jq '.nodes | with_entries(select(.key|match("_";""))) | keys[]' < "$lock_file")

if [ -n "$dupes" ]; then
  echo "Duplicate inputs found:"
  echo "$dupes"
  exit 1
fi
