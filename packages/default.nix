{
  self,
  inputs,
  ...
}: {
  perSystem = {pkgs, ...}: let
    packagePythonScript = self.lib.package.packagePythonScript;
    callPackage = pkgs.lib.customisation.callPackageWith (pkgs
      // inputs
      // {
        inherit packagePythonScript;
      });
  in {
    packages = {
      combine-blueprints = callPackage ./combine-blueprints {};
      command-palette = callPackage ./command-palette {};
      export-blueprints = callPackage ./export-blueprints {};
      factorio-blueprint-decoder = callPackage ./factorio-blueprint-decoder.nix {};
      nix-utils = callPackage ./nix-utils {};
      nixvim = callPackage ./nixvim {};
      openmw-dev = callPackage ./openmw-dev.nix {};
      openmw-luadata = callPackage ./openmw-luadata {};
      rebuild = callPackage ./rebuild {};
      resaver = callPackage ./resaver {};
      set-led-state = callPackage ./set-led-state {};
      skyrim-utils = callPackage ./skyrim-utils {};
      spriggit = callPackage ./spriggit.nix {};
    };
  };
}
