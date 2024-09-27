{self, ...}: let
  mkHost = self.lib.host.mkHost;
in {
  flake.nixosConfigurations = {
    canterbury = mkHost ./canterbury/configuration.nix;
    rocinante = mkHost ./rocinante/configuration.nix;
  };
}
