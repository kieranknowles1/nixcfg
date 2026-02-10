#!/usr/bin/env nu

def collect_data [
  assets: path
] {
  cd $assets

  let head = git rev-parse HEAD

  let files = ls **/* | where type == file | get name
  let hashes = sha256sum ...$files | split row "\n" | each {split row "  " | reverse} | into record
  {
    rev: $head,
    files: $hashes
  }
}

# Synchronise asset hashes with an external repository
def main [] {
  collect_data ~/Documents/src/nixcfg-assets/ | save --force asset-manifest.json
}
