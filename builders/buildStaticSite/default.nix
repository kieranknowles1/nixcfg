{
  php,
  pandoc,
  graphviz,
  stdenv,
}:
/*
Build a truly static site with no runtime overhead. Files are transformed at
into plain HTML.

Files in a `.build-only` directory are available to the builder, but not
built themselves. Intended for resources that may or may not be required.

Supported file types and their transformations:
- Dot: Rendered to SVG with Graphviz. Default style is overridden. to work
  better in a dark theme.
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
    buildInputs = [
      php
      pandoc
      graphviz
    ];

    CUSTOM_MARKDOWN_STYLE = useCustomMarkdownStyle;

    buildPhase = ''
      export BUILD_HELPERS="${./.}"
      bash ${./buildPhase.sh} "$src" "$out"
    '';
  })
