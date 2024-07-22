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
    src = inputs.src-factorio-blueprint-decoder;
  in
    pkgs.writers.writePython3 "factorio-blueprint-decoder" {} (builtins.readFile "${src}/decode");

  nixvim = import ./nixvim {inherit pkgs inputs;};

  rebuild = import ./rebuild {inherit pkgs;};

  skyrim-utils = import ./skyrim-utils {inherit pkgs;};
}
