#!/usr/bin/env bash
set -euo pipefail
src="$1"
out="$2"

# For Pandoc reproducibility
export SOURCE_DATE_EPOCH=0

# Replace the given file's extension with HTML
replaceExtension() {
  file="$1"
  echo "${file%.*}.html"
}

buildPandoc() {
  file="$1"
  out_html="$2"

  # Grab the title from the first line of the file
  title=$(head -n 1 "$file" | sed 's|^# ||')

  # Remove the title as Pandoc will add it back
  tmpfile=$(mktemp)
  tail -n +2 "$file" > "$tmpfile"

  extraArgs=()
  if [[ "$CUSTOM_MARKDOWN_STYLE" == true ]]; then
    extraArgs+=(--css "style.css")
  else
    # Tweak the default CSS to be more to my liking
    extraArgs+=(
      -V "maxwidth=40em"
      -V "mainfont=DejaVuSansM Nerd Font"
      -V "monofont=DejaVuSansM Nerd Font Mono"
      --include-after-body "$BUILD_HELPERS/markdownExtraEnd.html"
    )
  fi

  pandoc \
    "${extraArgs[@]}" \
    --standalone \
    --from markdown --to html \
    --metadata title="$title" \
    --fail-if-warnings \
    "$tmpfile" --output "$out_html"
  rm "$tmpfile"

  # Replace .md with .html in links, such that href="<file>.md#<anchor>" becomes href="<file>.html#<anchor>"
  # --regexp-extended - Removes the need for escaping parentheses (badly named option)
  sed --regexp-extended --in-place 's|href="([^"]*).md([^"]*)|href="\1.html\2|g' "$out_html"
}

mkdir -p "$out"
while IFS= read -r -d "" file; do
  relative=$(realpath --no-symlinks --relative-to="$src" "$file")
  # The equivalent input path in the output directory
  out_relative="$out/$relative"
  # $out_relative with any extension replaced with .html
  out_html=$(replaceExtension "$out_relative")

  echo "Processing $file"

  mkdir -p "$(dirname "$out_relative")"

  if [[ "$file" == *.php ]]; then
    php -f "$BUILD_HELPERS/buildFile.php" "$file" > "$out_html"
  elif [[ "$file" == *.md ]]; then
    buildPandoc "$file" "$out_html"
  else
    cp "$file" "$out_relative"
  fi
  # -L : Follow symlinks
  # -type f : Only files, not directories
  # -print0 : Separate with null bytes
  # -not -path : Exclude .build-only
done < <(find -L "$src" -type f -not -path '**/.build-only/*' -print0)
