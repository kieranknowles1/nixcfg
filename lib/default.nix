{
  flake-parts-lib,
  lib,
  ...
}: {
  options.flake = let
    inherit (flake-parts-lib) mkSubmoduleOptions;
    inherit (lib) mkOption types;
  in
    mkSubmoduleOptions {
      lib = mkOption {
        type = types.lazyAttrsOf types.attrs;
        default = {};
        description = ''
          An extension of `nixpkgs.lib`
        '';
      };
    };

  imports = [
    ./attrset.nix
    ./docs.nix
    ./host.nix
    ./shell.nix
  ];
}
