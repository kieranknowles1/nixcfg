{
  flake-parts-lib,
  lib,
  inputs,
  ...
}: {
  # TODO: Flake schemas once they're merged
  imports = [
    # TODO: Is there a tidier way to declare the output?
    (flake-parts-lib.mkTransposedPerSystemModule {
      name = "builders";
      option = let
        inherit (lib) mkOption types;
      in
        mkOption {
          type = types.lazyAttrsOf types.anything;
          default = {};
          description = ''
            Architecture-specific builders for reuse in other modules.
          '';
        };
      file = ./.;
    })
    {
      perSystem = {pkgs, ...}: {
        builders = let
          callPackage = lib.customisation.callPackageWith (pkgs // inputs);
        in {
          buildGodotApp = callPackage ./buildGodotApp.nix {};
          buildScript = callPackage ./buildScript.nix {};
          fromHeif = callPackage ./fromHeif.nix {};
          mkFunctionDocs = callPackage ./mkFunctionDocs.nix {};
          mkOptionDocs = callPackage ./mkOptionDocs.nix {};
        };
      };
    }
  ];
}
