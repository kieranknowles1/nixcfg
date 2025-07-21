{
  self,
  hostPlatform,
  stdenv,
}:
self.builders.${hostPlatform.system}.buildStaticSite {
  name = "portfolio";

  src = stdenv.mkDerivation {
      name = "portfolio-src";
      src = ./src;
      buildPhase = ''
        mkdir -p $out $out/.build-only
        cp -r $src/* $out
        ln -s ${self.assets.mdi-icons}/svg $out/.build-only/mdi-icons
        ln -s ${self.assets.simple-icons}/icons $out/.build-only/simple-icons
      '';
    };
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

      You don't need a static site generator that spits out 2000 lines of HTML. Just
      use PHP, and make your code deterministic.\[5\]

      \[1\]: https://gist.github.com/Restuta/cda69e50a853aa64912d\
      \[2\]: https://pressgazette.co.uk/website-tracking-software/\
      \[3\]: https://www.bbc.co.uk/news/technology-46508234
      \[4\]: http://bettermotherfuckingwebsite.com/
      \[5\]: https://rosswintle.uk/2021/12/hang-on-php-is-a-static-site-generator/
    '';
  };
}
