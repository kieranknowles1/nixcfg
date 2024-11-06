#!/usr/bin/env bash
set -e

API_ROOT="http://127.0.0.1:37840/etapi"
API_KEY=$(cat ~/.local/share/trilium-data/token)
DST_DIR=~/Documents/notes-export
META_FILE="$DST_DIR/!!!meta.json"

export_file=$(mktemp)
echo "Feching notes from $API_ROOT to $export_file"
curl --header "Authorization: $API_KEY" "$API_ROOT/notes/root/export" > "$export_file"

echo "Unzipping $export_file to $DST_DIR"
unzip -q -o "$export_file" -d "$DST_DIR"
rm "$export_file"

echo "Cleaning up export"

# Discard the isExpanded property from all notes, as it is part of the UI state
tmp_file=$(mktemp)
jq --indent 1 'walk(if type == "object" then del(.isExpanded) end)' "$META_FILE" > "$tmp_file"
mv "$tmp_file" "$META_FILE"

# Pass loose JSON through jq to format it nicely
# Trilium dumps everything on one line, which is hard to read diffs of
while IFS= read -r -d '' file; do
  tmp_file=$(mktemp)
  jq --indent 1 . "$file" > "$tmp_file"
  mv "$tmp_file" "$file"
done < <(find "$DST_DIR" -type f -name '*.json' -print0)


echo "Committing changes to git"
repo_clean=$(git -C "$DST_DIR" status --porcelain | wc -l)
if [ "$repo_clean" -gt 0 ]; then
  git -C "$DST_DIR" add .
  git -C "$DST_DIR" commit -m "Update on $(date +'%Y-%m-%d %H:%M:%S')" > /dev/null
  # git -C "$DST_DIR" push
else
  echo "No changes since last export"
fi
