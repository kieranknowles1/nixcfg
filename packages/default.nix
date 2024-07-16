{
  pkgs,
  flakeLib,
  inputs,
}: let
  # Usage: writePython3 "name" {environment} contents
  # contents can come from builtins.readFile, but not a Git repository
  # To use a git repo, add it as a flake input with flake = false.
  writePython3Bin = pkgs.writers.writePython3Bin;

  # Write a Python file without checking the syntax
  writePythonFile = name: environment: file: writePython3Bin name environment ''
    # flake8: noqa
    ${builtins.readFile file}
  '';
in {
  # TODO: Add metadata
  combine-blueprints = writePythonFile "combine-blueprints" {} ./combine-blueprints.py;

  edit-config = import ./edit-config {inherit pkgs;};

  # TODO: Add metadata
  export-blueprints = writePythonFile "export-blueprints" {} ./export-blueprints.py;

  # TODO: Add metadata
  factorio-blueprint-decoder = writePythonFile "factorio-blueprint-decoder" {} "${inputs.src-factorio-blueprint-decoder}/decode";

  nixvim = import ./nixvim {inherit pkgs inputs;};

  rebuild = import ./rebuild {inherit pkgs;};

  skyrim-utils = import ./skyrim-utils {inherit pkgs;};
}
