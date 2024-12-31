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
- Markdown: Converted to HTML with Pandoc and optionally styled with `style.css`.
- All other files: Copied to the output directory.

Spaces are strongly discouraged and not guaranteed to work. No technical reason,
just I can't be bothered to work around Bash's quirks.
*/
{
  # If true, the site will use its own `style.css` for Markdown instead of Pandoc's.
  useCustomMarkdownStyle ? false,
  ...
}@args:
stdenv.mkDerivation (args
  // {
    buildInputs = [php pandoc];

    inherit useCustomMarkdownStyle;

    buildPhase = ''
      BUILD_SRC="${./.}"
      ${builtins.readFile ./buildPhase.sh}
    '';
  })
