{
  flake-parts-lib,
  lib,
  ...
}: {
  # TODO: Flake schemas once they're merged
  # TODO: Is there a tidier way to do this?
  imports = [
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
    ./image.nix
  ];
}
