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
        relative=$(realpath --relative-to=$src $file)
        out_relative=$out/$relative

        # Exclude files in .build-only
        if [[ $file == *"/.build-only/"* ]]; then
          continue
        fi

        mkdir -p $(dirname $out_relative)

        if [[ $file == *.php ]]; then
          # Transform PHP to HTML
          php -f ${./buildFile.php} $file > $out/$(basename $out_relative .php).html
        else
          # Copy all other files
          cp $file $out_relative
        fi
      done < <(find $src -type f -print0)
    '';
  })
