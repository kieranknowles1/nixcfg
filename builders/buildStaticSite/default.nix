{
  graphviz,
  html-tidy,
  jq,
  php,
  stdenv,
  typescript,
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
- TypeScript: Checked and compiled to JavaScript
- All other files: Copied to the output directory.

The following files are checked after build:
- HTML: Passed through html-tidy

Spaces in filenames are strongly discouraged and not guaranteed to work. No technical
reason, just I can't be bothered to work around Bash's quirks.
*/
args:
stdenv.mkDerivation (args
  // {
    buildInputs = [
      graphviz
      html-tidy
      jq
      php
      typescript
    ];

    BUILD_HELPERS = ./.;

    buildPhase = ''
      ${builtins.readFile ./buildPhase.sh}

      # checkPhase is skipped when cross-compiling, in this case
      # we can run it anyway
      ${builtins.readFile ./checkPhase.sh}
    '';
  })
