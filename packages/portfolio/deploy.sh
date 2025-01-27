#!/usr/bin/env bash
set -euo pipefail

HOST=razorback.local
DST=/home/kieran/portfolio

# TODO: This is a temporary solution until the server is running NixOS proper
# Build portfolio locally and push to server
nix build .#portfolio
ssh "$HOST" "mkdir -p $DST"
scp -r result/* "$HOST:$DST"
# Nix results are read-only by default, which would cause subsequent scps to fail
# We don't need to touch output files to update mtime for nginx, scp does that for us
ssh "$HOST" "chmod -R u+w $DST"
