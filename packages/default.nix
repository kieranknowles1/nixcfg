{
  pkgs,
  flakeLib,
}: let
  packagePythonScript = flakeLib.package.packagePythonScript;

  factorioDecoderSrc = pkgs.fetchFromGitHub {
    owner = "asheiduk";
    repo = "factorio-blueprint-decoder";
    # Fixes error with turrets, hasn't been merged yet
    rev = "bugfix/byte-4d";
    hash = "sha256-tPE0/g0V11Qy4KSxZ2HlANCJYs5q/3YeHJeriIddgII=";
  };
in {
  clean-skse-cosaves = packagePythonScript "clean-skse-cosaves" ./clean-skse-cosaves.py "1.0.1";

  combine-blueprints = packagePythonScript "combine-blueprints" ./combine-blueprints.py "1.0.0";

  # TODO: Add a script to copy blueprints from the game to the repo, then re-encode them
  factorio-blueprint-decoder = packagePythonScript "factorio-blueprint-decoder" "${factorioDecoderSrc}/decode" "0.1.0";
}
