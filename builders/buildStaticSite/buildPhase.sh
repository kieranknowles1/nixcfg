#!/usr/bin/env bash
set -euo pipefail
# Silence Nix warnings
# shellcheck disable=SC2269
src="$src"
# shellcheck disable=SC2269
out="$out"

FONT="DejaVuSansM Nerd Font"

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
