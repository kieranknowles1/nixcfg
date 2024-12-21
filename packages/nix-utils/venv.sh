#!/usr/bin/env bash
set -euo pipefail

# Usage: venv <name=venv>

venv="${1:-venv}"

if [ ! -d "$venv" ]; then
  echo "Could not find virtual environment: $venv"
  return 1
fi

# This script is meant to be used anywhere. We check for the venv above.
# shellcheck disable=SC1091
source "$venv/bin/activate" # Activate the virtual environment. This exports all needed variables.
exec "$SHELL" # Return to the user's preferred shell.
