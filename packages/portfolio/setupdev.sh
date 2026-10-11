#!/usr/bin/env bash
set -euo pipefail

chmod -R +rw assets/ || true
rm -r assets || true

# Symlinks confuse node
nix build .#portfolio.passthru.assets --out-link result
cp --dereference -r result/ assets

./getexifdata.sh
