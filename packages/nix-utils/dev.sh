#!/usr/bin/env bash
set -euo pipefail
exec nix develop ".#${1:-default}"
