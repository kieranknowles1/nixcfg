#!/usr/bin/env bash
set -euo pipefail
# Silence Nix warnings
# shellcheck disable=SC2269
src="$src"
# shellcheck disable=SC2269
out="$out"

# For Pandoc reproducibility
export SOURCE_DATE_EPOCH=0
FONT="DejaVuSansM Nerd Font"
MONOFONT="$FONT Mono"

replaceExtension() {
  file="$1"
  new_extension="$2"
  echo "${file%.*}.$new_extension"
}

# Very simple removal of comments. Definitely has edge cases that aren't
# covered
stripComments() {
  sed --regexp-extended -e 's|/\*.*\*/||' -e 's|(.+)//.+|\1|' "$@"
}
# TSC doesn't support manually specifying a config file, so manually convert tsconfig options into CLI arguments
IFS=' ' read -r -a TS_OPTS <<< "$(stripComments "$BUILD_HELPERS/tsconfig.json" | jq -r '.compilerOptions | to_entries | map("--\(.key) \(.value)") | .[]')"

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
      -V "lang=en-GB"
      -V "maxwidth=40em"
      -V "mainfont=$FONT"
      -V "monofont=$MONOFONT"
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

  echo "Processing $file"

  mkdir -p "$(dirname "$out_relative")"

  extension="${file##*.}"
  case "$extension" in
    dot)
      dot \
        -Gbgcolor=transparent -Nfillcolor=lightgrey -Nfontname="$FONT" \
        -Nstyle=filled -Ecolor=white \
        -Tsvg "$file" -o "$(replaceExtension "$out_relative" "svg")"
      ;;
    md)
      buildPandoc "$file" "$(replaceExtension "$out_relative" "html")"
      ;;
    php)
      php -f "$BUILD_HELPERS/buildFile.php" "$file" > "$(replaceExtension "$out_relative" "html")"
      ;;
    ts)
      tsc "${TS_OPTS[@]}" "$file" --outFile "$(replaceExtension "$out_relative" "js")"
      ;;
    *)
      cp "$file" "$out_relative"
      ;;
  esac
  # -L : Follow symlinks
  # -type f : Only files, not directories
  # -print0 : Separate with null bytes
  # -not -path : Exclude .build-only
done < <(find -L "$src" -type f -not -path '**/.build-only/*' -print0)
