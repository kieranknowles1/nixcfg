{
  pkgs,
  lib,
  inputs,
  self,
  system,
  ...
}: let
  callPackage = lib.customisation.callPackageWith (pkgs
    // inputs
    // self.builders.${system});
in rec {
  activate-mutable = callPackage ./activate-mutable {};
  combine-blueprints = callPackage ./combine-blueprints {};
  command-palette = callPackage ./command-palette {};
  checkleak = callPackage ./checkleak {};
  export-blueprints = callPackage ./export-blueprints {inherit factorio-blueprint-decoder;};
  export-notes = callPackage ./export-notes {};
  extract = callPackage ./extract {};
  factorio-blueprint-decoder = callPackage ./factorio-blueprint-decoder.nix {};
  keyboardvis = callPackage ./keyboardvis {};
  nix-utils = callPackage ./nix-utils {};
  openmw-luadata = callPackage ./openmw-luadata {};
  portfolio = callPackage ./portfolio {};
  rebuild = callPackage ./rebuild {};
  resaver = callPackage ./resaver {};
  set-led-state = callPackage ./set-led-state {};
  skyrim-utils = callPackage ./skyrim-utils {};
  spriggit = callPackage ./spriggit.nix {};
  todos = callPackage ./todos {};
  tlro = callPackage ./tlro {};
}
