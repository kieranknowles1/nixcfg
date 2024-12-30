{
  php,
  stdenv,
  # This is a more complex builder, so I think it justifies using Nu over Bash
  nushell
}:
/*
Build a truly static site with no runtime overhead. Files are transformed at
into plain HTML.

PHP files will be transformed to HTML. All others will be copied.
Files can be made available to the builder but excluded from output by default
by placing then in a directory named `.build-only`.
*/
args:
stdenv.mkDerivation (args
  // {
    buildInputs = [php nushell];

    buildPhase = ''
      nu ${./buildPhase.nu} "$src" "$out" --buildPhp ${./buildFile.php}
    '';
  })
