{
  php,
  pandoc,
  stdenv,
}:
/*
Build a truly static site with no runtime overhead. Files are transformed at
into plain HTML.

Files can be made available to the builder but excluded from output by default
by placing then in a directory named `.build-only`.

Supported file types and their transformations:
- PHP: Executed with a safe mode enabled interpreter. Output is saved as HTML.
- Markdown: Converted to HTML with Pandoc using the site's `style.css`.
- All other files: Copied to the output directory.

Spaces are strongly discouraged and not guaranteed to work. No technical reason,
just I can't be bothered to work around Bash's quirks.
*/
args:
stdenv.mkDerivation (args
  // {
    buildInputs = [php pandoc];

    buildPhase = ''
      # For Pandoc reproducibility
      export SOURCE_DATE_EPOCH=0

      mkdir -p $out
      while IFS= read -r -d "" file; do
        relative=$(realpath --relative-to=$src $file)
        out_relative=$out/$relative

        # Exclude files in .build-only
        if [[ "$file" == *"/.build-only/"* ]]; then
          continue
        fi

        mkdir -p $(dirname $out_relative)

        if [[ "$file" == *.php ]]; then
          php -f ${./buildFile.php} "$file" > "$out/$(basename $out_relative .php)".html
        elif [[ "$file" == *.md ]]; then
          pandoc \
            --standalone \
            --css style.css \
            --fail-if-warnings \
            "$file" --output "$out/$(basename $out_relative .md).html"

          # Replace .md with .html in links. Assumes that .md is always followed by a quote for the end of href=""
          sed -i 's|\.md"|\.html"|g' "$out/$(basename $out_relative .md).html"
        else
          # Copy all other files
          cp "$file" $out_relative
        fi
      done < <(find $src -type f -print0)
    '';
  })
