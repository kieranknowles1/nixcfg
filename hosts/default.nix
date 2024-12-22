{self, ...}: let
  inherit (self.lib.host) mkHost;
in {
  flake.nixosConfigurations = {
    canterbury = mkHost ./canterbury/configuration.nix;
    rocinante = mkHost ./rocinante/configuration.nix;
    tycho = mkHost ./tycho/configuration.nix;
  };
}
