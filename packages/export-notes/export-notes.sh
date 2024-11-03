#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <src-file.zip>"
  exit 1
fi

SRC_FILE=$1
DST_DIR=~/Documents/notes-export
META_FILE="$DST_DIR/!!!meta.json"

echo "Unzipping $SRC_FILE to $DST_DIR"
unzip -q -o "$SRC_FILE" -d "$DST_DIR"


echo "Cleaning up $DST_DIR"
# Discard the isExpanded property from all notes, as it is part of the UI state
# cat <<< "$(jq --indent 1 'walk(if type == "object" then del(.isExpanded) end)' "$META_FILE")" > "$META_FILE"
tmp_file=$(mktemp)
jq --indent 1 'walk(if type == "object" then del(.isExpanded) end)' "$META_FILE" > "$tmp_file"
mv "$tmp_file" "$META_FILE"


echo "Committing changes to git"
repo_clean=$(git -C "$DST_DIR" status --porcelain | wc -l)
if [ "$repo_clean" -gt 0 ]; then
  commit_message="Update from $(basename "$SRC_FILE") on $(date +'%Y-%m-%d %H:%M:%S')"
  git -C "$DST_DIR" add .
  git -C "$DST_DIR" commit -m "$commit_message"
  # git -C "$DST_DIR" push
else
  echo "No changes since last export"
fi
