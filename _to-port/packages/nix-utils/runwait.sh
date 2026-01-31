#!/usr/bin/env bash
set -euo pipefail

status=0
"$@" || status=$?

if [[ "$status" -eq 0 ]]; then
  echo "Command complete"
else
  echo "Command failed with code $status"
fi

echo "Press Control+C or close the window to exit."
while true; do sleep 1d; done
