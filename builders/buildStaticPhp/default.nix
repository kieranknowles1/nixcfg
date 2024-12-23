{
  php,
  stdenv,
}:
/*
Build a static web app with PHP, transformed into HTML at build time.

PHP files will be transformed to HTML. All others will be copied.
Files can be made available to the builder but excluded from output by default
by placing then in a directory named `.build-only`.
*/
args:
stdenv.mkDerivation (args
  // {
    buildInputs = [php];

    buildPhase = ''
      mkdir -p $out
      while IFS= read -r -d "" file; do
        # Exclude files in .build-only
        if [[ $file == *"/.build-only/"* ]]; then
          continue
        fi

        if [[ $file == *.php ]]; then
          # Transform PHP to HTML
          php -f ${./buildFile.php} $file > $out/$(basename $file .php).html
        else
          # Copy all other files
          cp $file $out
        fi
      done < <(find $src -type f -print0)
    '';
  })
