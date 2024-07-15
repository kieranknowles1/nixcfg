{
  pkgs,
  flakeLib,
  inputs,
}: let
  packagePythonScript = flakeLib.package.packagePythonScript;
in {
  # TODO: Add metadata
  combine-blueprints = packagePythonScript "combine-blueprints" ./combine-blueprints.py "1.0.0";

  edit-config = import ./edit-config {inherit pkgs;};

  # TODO: Add metadata
  export-blueprints = packagePythonScript "export-blueprints" ./export-blueprints.py "1.0.0";

  # TODO: Add metadata
  factorio-blueprint-decoder = let
    src = pkgs.fetchFromGitHub {
      owner = "kieranknowles1";
      repo = "factorio-blueprint-decoder";
      rev = "turret_fix";
      hash = "sha256-SCcWptznd75ImsGlMl2Bj6z0er2Ila90vXuPPUBIkyI=";
    };
  in
    packagePythonScript "factorio-blueprint-decoder" "${src}/decode" "0.1.2";

  nixvim = import ./nixvim {inherit pkgs inputs;};

  rebuild = import ./rebuild {inherit pkgs;};

  skyrim-utils = import ./skyrim-utils {inherit pkgs;};
}
