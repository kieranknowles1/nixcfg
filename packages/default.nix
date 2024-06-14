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
  /**
    Capitalize the first letter of a string
   */
  capitalize = packagePythonScript "capitalize" ./capitalize.py "1.0.0";

  /**
    Replace all occurrences of argv[2] in argv[1] with argv[3]
   */
  replace = packagePythonScript "replace" ./replace.py "1.0.0";

  clean-skse-cosaves = packagePythonScript "clean-skse-cosaves" ./clean-skse-cosaves.py "1.0.1";

  # TOOD: Add a script to copy blueprints from the game to the repo, then re-encode them
  factorio-blueprint-decoder = packagePythonScript "factorio-blueprint-decoder" "${factorioDecoderSrc}/decode" "0.1.0";
}
