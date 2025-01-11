{
  self,
  inputs,
  lib,
  ...
}: {
  perSystem = {system, ...}: let
    # TODO: Set overrides at the flake level once there's a proper way to do so
    pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = builtins.attrValues self.overlays;
    };
    callPackage = lib.customisation.callPackageWith (pkgs
      // inputs
      // self.builders.${system});
  in {
    packages = {
      activate-mutable = callPackage ./activate-mutable {};
      combine-blueprints = callPackage ./combine-blueprints {};
      command-palette = callPackage ./command-palette {};
      export-blueprints = callPackage ./export-blueprints {};
      export-notes = callPackage ./export-notes {};
      factorio-blueprint-decoder = callPackage ./factorio-blueprint-decoder.nix {};
      nix-utils = callPackage ./nix-utils {};
      nixvim = callPackage ./nixvim {};
      openmw-luadata = callPackage ./openmw-luadata {};
      portfolio = callPackage ./portfolio {};
      rebuild = callPackage ./rebuild {};
      resaver = callPackage ./resaver {};
      set-led-state = callPackage ./set-led-state {};
      skyrim-utils = callPackage ./skyrim-utils {};
      spriggit = callPackage ./spriggit.nix {};
    };
  };
}
