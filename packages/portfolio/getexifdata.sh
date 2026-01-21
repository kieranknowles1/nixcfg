#!/usr/bin/env bash
set -euo pipefail

exiftool assets/photography/* -json > exif.json
