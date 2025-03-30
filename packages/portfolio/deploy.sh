#!/usr/bin/env bash
set -euo pipefail

SECRETSROOT=~/.config/sops-nix/secrets/portfolio/
HOST=razorback.local
DST=/home/kieran/portfolio
ZONE_ID=$(cat "$SECRETSROOT/cfzone")
CLEAR_CACHE_TOKEN=$(cat "$SECRETSROOT/cfclearcache")

# SC2029 - $ expansion occurs client-side. This is the expected behaviour

# TODO: This is a temporary solution until the server is running NixOS proper
# Build portfolio locally and push to server
nix build .#portfolio
# shellcheck disable=SC2029
ssh "$HOST" "mkdir -p $DST"
scp -r result/* "$HOST:$DST"
# Nix results are read-only by default, which would cause subsequent scps to fail
# We don't need to touch output files to update mtime for nginx, scp does that for us
# shellcheck disable=SC2029
ssh "$HOST" "chmod -R u+w $DST"

curl "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/purge_cache" \
  --header 'Content-Type: application/json' \
  --header "Authorization: Bearer $CLEAR_CACHE_TOKEN" \
  --data '{"purge_everything": true}'
