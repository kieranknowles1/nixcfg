#!/usr/bin/env bash
set -euo pipefail
exec nix develop "$FLAKE#${1:-default}"
