#!/usr/bin/env bash
set -euo pipefail
# Wrapper for Resaver that lazily installs it if necessary.

API_KEY_FILE="$HOME/.config/sops-nix/secrets/nexusmods/apikey"
RESAVER_DIR="$HOME/.cache/resaver"
RESAVER_BIN="$RESAVER_DIR/target/ReSaver.jar"

GAME_ID="skyrimspecialedition"
MOD_ID="5031"
FILE_ID="424051"

API_URL="https://api.nexusmods.com/v1/games/$GAME_ID/mods/$MOD_ID/files/$FILE_ID/download_link.json"

# Check if Resaver is installed
if [ ! -d "$RESAVER_DIR" ]; then
  echo "Resaver not found. Downloading"

  api_key=$(cat "$API_KEY_FILE")
  # Get the first download link. Other links are for regional mirrors which we don't care about.
  download_link=$(curl -X GET -H "accept: application/json" -H "apikey: $api_key" "$API_URL" | jq --raw-output '.[0].URI')
  # The provided link will contain spaces, which must be url-encoded
  download_link=${download_link// /%20}

  outfile="$(mktemp).7z"
  curl -o "$outfile" "$download_link"

  mkdir -p "$RESAVER_DIR"
  7z x "$outfile" -o"$RESAVER_DIR"
fi

# Run Resaver
# We exec, so the Java process replaces this script. This makes the
# script more transparent to the caller.
exec java -jar "$RESAVER_BIN" "$@"
