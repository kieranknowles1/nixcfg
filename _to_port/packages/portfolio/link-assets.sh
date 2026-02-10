#!/usr/bin/env bash
set -euo pipefail
chmod -R +w assets/photography || true
rm -r assets || true
nix build .#portfolio.passthru.assets
mkdir assets
cp result/photography assets --recursive --dereference
./getexifdata.sh
