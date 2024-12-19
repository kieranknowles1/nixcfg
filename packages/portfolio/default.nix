{
  stdenv,
  fetchFromGitHub,
  php,
}:
stdenv.mkDerivation {
  name = "portfolio";
  src = ./src;

  buildInputs = [php];

  buildPhase = let
    # Like these for generic icons
    mdi-icons = fetchFromGitHub {
      owner = "Templarian";
      repo = "MaterialDesign";
      # Master as of 19/12/24
      rev = "ce55b68ba7308fef54003d5c588343eeac30ff7a";
      hash = "sha256-S5EugaVJpFxLYM6s+Ujd8vyD6MUa+sxwQrBGTT+ve6w=";
    };

    # Brand icons that are deliberately excluded from the Material Design set
    simple-icons = fetchFromGitHub {
      owner = "simple-icons";
      repo = "simple-icons";
      tag = "13.21.0";
      hash = "sha256-hBb4jIGxdlNE/Om1cpPYHpw4YSD/kkYOdZpXr63wM+w=";
    };
  in ''
    mkdir -p $out
    ln -s ${mdi-icons}/svg ./mdi-icons
    ln -s ${simple-icons}/icons ./simple-icons

    # Errors are printed to stdout, so redirect output to the output HTML
    # and build log.
    php -f index.php | tee $out/index.html
    cp $src/style.css $out/style.css
  '';

  meta = {
    description = "My personal portfolio";

    longDescription = ''
      My portfolio for job applications listing my projects and skills. As I'm in to
      self hosting, it is intended to be hosted on my own server.

      # Features

      It's a static website. You don't need 566KB of JavaScript\[1\], 82
      trackers\[2\], and God knows how many ads to display a simple portfolio.\[3\]

      You don't need a static site generator that spits out 2000 lines of HTML. Just
      use PHP, and make your code deterministic.\[4\]

      \[1\]: https://gist.github.com/Restuta/cda69e50a853aa64912d\
      \[2\]: https://pressgazette.co.uk/website-tracking-software/\
      \[3\]: http://bettermotherfuckingwebsite.com/
      \[4\]: https://rosswintle.uk/2021/12/hang-on-php-is-a-static-site-generator/
    '';
  };
}
