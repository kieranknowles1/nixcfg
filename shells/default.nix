{
  inputs,
  self,
  ...
}: {
  perSystem = {system, ...}: let
    pkgs = import inputs.nixpkgs {
      inherit system;
      # TODO: Remove this once flake-parts has a proper way of handling overlays
      overlays = builtins.attrValues self.overlays;
    };
    callPackage = pkgs.callPackage;
  in {
    devShells = {
      # `default.nix` is already used for this file, so use a different name
      default = callPackage ./defaultShell.nix {};
      openmw = callPackage ./openmw.nix {};
      rust = callPackage ./rust.nix {};
    };
  };
}
