#!/usr/bin/env bash
set -euo pipefail

# For Pandoc reproducibility
export SOURCE_DATE_EPOCH=0

buildPandoc() {
  file="$1"
  out_relative="$2"

  # Grab the title from the first line of the file
  title=$(head -n 1 "$file" | sed 's|^# ||')

  # Remove the title as Pandoc will add it back
  tmpfile=$(mktemp)
  tail -n +2 "$file" > $tmpfile

  pandoc \
    --standalone \
    --from markdown --to html \
    --css style.css \
    --metadata title="$title" \
    --fail-if-warnings \
    "$tmpfile" --output "$out/$(basename $out_relative .md).html"
  rm "$tmpfile"

  # Replace .md with .html in links. Assumes that .md is always followed by a quote for the end of href=""
  sed -i 's|\.md"|\.html"|g' "$out/$(basename $out_relative .md).html"
}

mkdir -p $out
while IFS= read -r -d "" file; do
  relative=$(realpath --no-symlinks --relative-to=$src $file)
  out_relative=$out/$relative

  # Exclude files in .build-only
  if [[ "$file" == *"/.build-only/"* ]]; then
    continue
  fi

  echo "Processing $file"

  mkdir -p $(dirname $out_relative)

  if [[ "$file" == *.php ]]; then
    php -f ${./buildFile.php} "$file" > "$out/$(basename $out_relative .php)".html
  elif [[ "$file" == *.md ]]; then
    buildPandoc "$file" "$out_relative"
  else
    cp "$file" $out_relative
  fi
  # -L : Follow symlinks
  # -type f : Only files, not directories
  # -print0 : Separate with null bytes
done < <(find -L $src -type f -print0)
