#!/usr/bin/env bash
set -e

# Very simple check for duplicate inputs, Nix names these with _<number>, so we can just check for those
# convention is to use hyphens, so this shouldn't have false positives
dupes=$(jq '.nodes | with_entries(select(.key|match("_";""))) | keys[]' < "$LOCK_FILE")

if [ -n "$dupes" ]; then
  echo "Duplicate inputs found:"
  echo "$dupes"
  exit 1
fi

# $out is a magic variable set by Nix
# shellcheck disable=SC2154
touch "$out" # Needed for the check to pass
