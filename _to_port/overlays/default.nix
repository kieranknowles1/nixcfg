{
  self,
  inputs,
  config,
  lib,
  ...
}: {
  # TODO: Remove this once flake-parts has a proper way of handling overlays
  perSystem = {system, ...}: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = with config.flake.overlays; [
        default
        overrides
      ];
    };
  };

  flake.overlays = {
    default = _final: prev: {
      flake =
        self.packages.${prev.system}
        // {
          inherit (self) lib;
        };
    };

    overrides = import ./overrides.nix {inherit inputs;};
    jemalloc-rpi = import ./jemalloc-rpi.nix;
  };
}
