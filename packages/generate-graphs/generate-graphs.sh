#!/usr/bin/env bash

dir="${1:-.}"

while read -r -d '' file; do
  svg_name="${file%.dot}.svg"
  echo "Generating $svg_name"
  dot -Tsvg "$file" -o "$svg_name"
done < <(find "$dir" -name '*.dot' -print0)
