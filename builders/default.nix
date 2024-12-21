{
  flake-parts-lib,
  lib,
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
          inherit (pkgs) callPackage;
        in {
          fromHeif = callPackage ./fromHeif.nix {};
          packagePythonScript = callPackage ./packagePythonScript.nix {};
        };
      };
    }
  ];
}
