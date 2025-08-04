#!/usr/bin/env bash
set -euo pipefail
"$@" && {
  status=0
  echo "Command complete"
} || {
  status=$?
  echo "Command failed with code $status"
}
echo "Press Control+C or close the window to exit."
while true; do sleep 1d; done
