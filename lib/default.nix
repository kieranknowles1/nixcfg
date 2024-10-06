{
  flake-parts-lib,
  lib,
  ...
}: let
  inherit (flake-parts-lib) mkSubmoduleOptions;
  inherit (lib) mkOption types;
in {
  options.flake = mkSubmoduleOptions {
    lib = mkOption {
      type = types.lazyAttrsOf types.attrs;
      default = {};
    };
  };

  imports = [
    ./attrset.nix
    ./docs.nix
    ./host.nix
    ./image.nix
    ./package.nix
    ./shell.nix
  ];
}
