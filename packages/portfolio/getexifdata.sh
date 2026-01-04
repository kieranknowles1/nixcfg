#!/usr/bin/env sh
set -euo pipefail

exiftool assets/photography/* -json > exif.json
