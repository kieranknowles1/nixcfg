{
  pkgs,
  flakeLib,
}: let
  packagePythonScript = flakeLib.package.packagePythonScript;

  factorioDecoderSrc = pkgs.fetchFromGitHub {
    owner = "kieranknowles1";
    repo = "factorio-blueprint-decoder";
    rev = "turret_fix";
    hash = "sha256-SCcWptznd75ImsGlMl2Bj6z0er2Ila90vXuPPUBIkyI=";
  };
in {
  clean-skse-cosaves = import ./clean-skse-cosaves {inherit pkgs;};

  combine-blueprints = packagePythonScript "combine-blueprints" ./combine-blueprints.py "1.0.0";

  export-blueprints = packagePythonScript "export-blueprints" ./export-blueprints.py "1.0.0";

  factorio-blueprint-decoder = packagePythonScript "factorio-blueprint-decoder" "${factorioDecoderSrc}/decode" "0.1.2";

  rebuild = import ./rebuild {inherit pkgs;};
}
