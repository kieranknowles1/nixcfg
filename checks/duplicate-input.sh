#!/usr/bin/env bash
set -e

lock_file="$1"

# Very simple check for duplicate inputs, Nix names these with _<number>, so we can just check for those
# convention is to use hyphens, so this shouldn't have false positives
dupes=$(jq '.nodes | with_entries(select(.key|match("_";""))) | keys[]' < "$lock_file")

if [ -n "$dupes" ]; then
  echo "Duplicate inputs found:"
  echo "$dupes"
  exit 1
fi
