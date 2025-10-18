#!/usr/bin/env bash
set -euo pipefail

showhelp() {
  cat <<EOF
Extract files into directories matching their names

Usage: $0 [files...]
  -h|--help:
    Show this help message and exit
  --notify:
    Send a notifaction when complete
EOF
  exit
}

files=()
notify=0
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      showhelp
      ;;
    --notify)
      notify=1
      ;;
    *)
      files+=("$1")
      ;;
  esac
  shift
done

if [[ ${#files[@]} -eq 0 ]]; then
  showhelp
fi

extractFile() {
  file="$1"

  type=$(xdg-mime query filetype "$file")
  out="${file%.*}"

  # None of this would be necessary if developers had decided on a consistent
  # interface for extracting files. But that ship sailed 20 years ago
  case "$type" in
    application/x-compressed-tar)
      tar -xzf "$file"
      ;;
    application/x-7z-compressed)
      7z x "$file" -o"$out"
      ;;
    application/zip)
      unzip "$file" -d "$out"
      ;;
    application/vnd.rar)
      mkdir -p "$out"
      unrar-free x "$file" "$out"
      ;;
    *)
      echo "Unsupported file type: $type" >&2
      exit 1
      ;;
  esac
}

for file in "${files[@]}"; do
  extractFile "$file" || {
    if [[ "$notify" -eq 1 ]]; then
      notify-send --category warning "Extract failed" "Extraction of $file failed."
    fi
    exit 1
  }
done

if [[ "$notify" -eq 1 ]]; then
  notify-send "Extract complete" "Extraction of ${#files[@]} files complete."
fi
