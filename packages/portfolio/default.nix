{
  stdenv,
  self,
  nodejs,
  importNpmLock,
  symlinkJoin,
  dejavu_fonts,
  font-awesome,
  typst,
}: let
  fonts = symlinkJoin {
    name = "fonts";
    paths = [
      dejavu_fonts
      font-awesome
    ];
  };

  typst' = typst.withPackages (ps: [
    ps.fontawesome_0_5_0
  ]);

  cv = stdenv.mkDerivation {
    name = "cv";
    src = ./cv;
    dontUnpack = true;

    nativeBuildInputs = [
      typst'
    ];

    buildPhase = ''
      mkdir -p $out
      for file in $src/*.typ; do
        filename=$(basename "$file" .typ)
        outfile="$out/''${filename}.pdf"
        typst compile "$file" "$outfile" --font-path=${fonts}
      done
    '';
  };
in
  stdenv.mkDerivation {
    name = "portfolio";
    src = ./.;

    buildInputs = [
      nodejs
    ];
    passthru.cv = cv;

    ASTRO_TELEMETRY_DISABLED = 1;

    MODULES = importNpmLock.buildNodeModules {
      package = builtins.fromJSON (builtins.readFile ./package.json);
      packageLock = builtins.fromJSON (builtins.readFile ./package-lock.json);
      inherit nodejs;
    };
    CV = cv;

    buildPhase = ''
      rm package.json package-lock.json
      ln -s $MODULES/node_modules node_modules
      ln -s $MODULES/package.json package.json
      ln -s $MODULES/package-lock.json package-lock.json

      npm run build
    '';

    installPhase = ''
      mv dist $out
      cp $CV/game-dev.pdf $out/cv-kieran-knowles.pdf
    '';

    meta = {
      inherit (self.lib) license;
      description = "My personal portfolio";
      longDescription = ''
        My portfolio for job applications listing my projects and skills. As I'm in to
        self hosting, it is intended to be hosted on my own server.
        # Features
        It's a static website. You don't need 566KB of JavaScript\[1\], 82
        trackers\[2\], 8 elements per word\[3\], and God knows how many ads
        to display a simple portfolio.\[4\]

        This rant made much more sense when I was using PHP, but Astro is a true
        SSG that spits out HTML, not JavaScript, and lets me avoid PHP, even though
        it is also a static site generator. \[5\]

        \[1\]: https://gist.github.com/Restuta/cda69e50a853aa64912d\
        \[2\]: https://pressgazette.co.uk/website-tracking-software/\
        \[3\]: https://www.bbc.co.uk/news/technology-46508234
        \[4\]: http://bettermotherfuckingwebsite.com/
        \[5\]: https://rosswintle.uk/2021/12/hang-on-php-is-a-static-site-generator/
      '';
    };
  }
