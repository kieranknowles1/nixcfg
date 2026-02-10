#!/usr/bin/env bash
set -euo pipefail

lock_file="$1/flake.lock"

EXPECTED=''

# Very simple check for duplicate inputs, Nix names these with _<number>,
# while the convention is to use hyphens. Shouldn't cause false positives unless
# something violates this convention.
dupes=$(jq '.nodes | with_entries(select(.key|match("_";""))) | keys[]' < "$lock_file")

if [ "$dupes" != "$EXPECTED" ]; then
  echo "Duplicate inputs found:"
  echo "$dupes"
  echo "Expected: $EXPECTED"
  exit 1
fi
