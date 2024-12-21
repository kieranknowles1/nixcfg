{
  self,
  inputs,
  ...
}: {
  perSystem = {system, ...}: let
    # TODO: Set overrides at the flake level once there's a proper way to do so
    pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = builtins.attrValues self.overlays;
    };
    callPackage = pkgs.lib.customisation.callPackageWith (pkgs
      // inputs
      // {
        inherit (self.builders.${system}) packagePythonScript;
      });
  in {
    packages = {
      activate-mutable = callPackage ./activate-mutable {};
      combine-blueprints = callPackage ./combine-blueprints {};
      command-palette = callPackage ./command-palette {};
      export-blueprints = callPackage ./export-blueprints {};
      export-notes = callPackage ./export-notes {};
      factorio-blueprint-decoder = callPackage ./factorio-blueprint-decoder.nix {};
      generate-graphs = callPackage ./generate-graphs {};
      nix-utils = callPackage ./nix-utils {};
      nixvim = callPackage ./nixvim {};
      openmw-dev = callPackage ./openmw-dev.nix {};
      openmw-luadata = callPackage ./openmw-luadata {};
      portfolio = callPackage ./portfolio {};
      rebuild = callPackage ./rebuild {};
      resaver = callPackage ./resaver {};
      set-led-state = callPackage ./set-led-state {};
      skyrim-utils = callPackage ./skyrim-utils {};
      spriggit = callPackage ./spriggit.nix {};
      trilium-next-desktop = callPackage ./trilium-next-desktop.nix {};
    };
  };
}
