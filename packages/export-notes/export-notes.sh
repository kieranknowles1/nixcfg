#!/usr/bin/env bash
set -euo pipefail

# This is meant to be used from the command palette, so keep stdout brief.
log() {
  echo "$(date +'%H:%M:%S') $1"
}

API_ROOT="http://127.0.0.1:37840/etapi"
API_KEY=$(cat "$API_KEY_FILE")
META_FILE="$DST_DIR/!!!meta.json"
FORMAT="markdown"

if [ ! -d "$DST_DIR/.git" ]; then
  log "No git repository found at $DST_DIR, aborting"
  exit 1
fi

export_file=$(mktemp)
log "Feching notes from $API_ROOT to $export_file"
curl --header "Authorization: $API_KEY" "$API_ROOT/notes/root/export?format=$FORMAT" > "$export_file" -Ss

log "Fetched $(du -k "$export_file" | cut -f1)KB of data"
log "Unzipping $export_file to $DST_DIR"
# Notes may have been moved or deleted. Remove the old notes directory to avoid stale data.
rootNoteDir=$(jq --raw-output '.files[0].dirFileName' < "$META_FILE")

if [ -d "$DST_DIR/$rootNoteDir" ]; then
  rm -rf "${DST_DIR:?}/${rootNoteDir:?}"
fi
unzip -q -o "$export_file" -d "$DST_DIR"
rm "$export_file"

log "Cleaning up export"

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


log "Committing changes to git"
repo_clean=$(git -C "$DST_DIR" status --porcelain | wc -l)
if [ "$repo_clean" -gt 0 ]; then
  log "Changes detected, committing to git"
  git -C "$DST_DIR" add .
  git -C "$DST_DIR" commit -m "Update on $(date +'%Y-%m-%d %H:%M:%S')" > /dev/null
  git -C "$DST_DIR" push
else
  log "No changes since last export"
fi
