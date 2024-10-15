#!/usr/bin/env bash

# Usage: venv <name=venv>

venv="${1:-venv}"

source "$venv/bin/activate" # Activate the virtual environment. This exports all needed variables.
exec "$SHELL" # Return to the user's preferred shell.
