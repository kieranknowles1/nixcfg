{
  self,
  inputs,
  ...
}: {
  perSystem = {system, ...}: let
    inherit (self.lib.package) packagePythonScript;

    # TODO: Set overrides at the flake level once there's a proper way to do so
    pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = builtins.attrValues self.overlays;
    };
    callPackage = pkgs.lib.customisation.callPackageWith (pkgs
      // inputs
      // {
        inherit packagePythonScript;
      });
  in {
    packages = {
      activate-mutable = callPackage ./activate-mutable {};
      combine-blueprints = callPackage ./combine-blueprints {};
      command-palette = callPackage ./command-palette {};
      export-notes = callPackage ./export-notes {};
      export-blueprints = callPackage ./export-blueprints {};
      factorio-blueprint-decoder = callPackage ./factorio-blueprint-decoder.nix {};
      generate-graphs = callPackage ./generate-graphs {};
      nix-utils = callPackage ./nix-utils {};
      nixvim = callPackage ./nixvim {};
      openmw-dev = callPackage ./openmw-dev.nix {};
      openmw-luadata = callPackage ./openmw-luadata {};
      rebuild = callPackage ./rebuild {};
      resaver = callPackage ./resaver {};
      set-led-state = callPackage ./set-led-state {};
      skyrim-utils = callPackage ./skyrim-utils {};
      spriggit = callPackage ./spriggit.nix {};
      trilium-next-desktop = callPackage ./trilium-next-desktop.nix {};
    };
  };
}
