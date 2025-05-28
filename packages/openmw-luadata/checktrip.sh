#!/usr/bin/env bash
set -euo pipefail

decode() {
  cargo run decode "$1"
}

checkFile() {
  src="$1"

  tmpjson=$(mktemp)
  tmpbin=$(mktemp)

  # Binary files from OpenMW are non-deterministic, so we compare JSON outputs
  # instead of binaries. This will not work if something is dropped entirely,
  # but should catch most round-trip errors
  decode "$src" > "$tmpjson"
  cargo run encode --input "$tmpjson" --output "$tmpbin"

  diff <(decode "$src") <(decode "$tmpbin")
  rm "$tmpjson" "$tmpbin"
}

checkFile ~/.config/openmw/player_storage.bin
checkFile ~/.config/openmw/global_storage.bin
