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
- Markdown: Converted to HTML with Pandoc.
  - If `useCustomMarkdownStyle` is true, the site will use its own `style.css`.
  - Otherwise, a tweaked version of Pandoc's default style is used plus a nerd
    font for icons. This is assumed to be available in the visitor's browser.
- All other files: Copied to the output directory.

Spaces are strongly discouraged and not guaranteed to work. No technical reason,
just I can't be bothered to work around Bash's quirks.
*/
{
  # If true, the site will use its own `style.css` for Markdown instead of Pandoc's.
  useCustomMarkdownStyle ? false,
  ...
} @ args:
stdenv.mkDerivation (args
  // {
    buildInputs = [php pandoc];

    CUSTOM_MARKDOWN_STYLE = useCustomMarkdownStyle;

    buildPhase = ''
      BUILD_HELPERS="${./.}"
      bash ${./buildPhase.sh} "$src" "$out"
    '';
  })
