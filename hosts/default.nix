{
  self,
  inputs,
  ...
}: let
  inherit (self.lib.host) mkHost;
  mkDefaultHost = mkHost inputs.nixpkgs.lib.nixosSystem {};
  mkRpiHost = mkHost inputs.nixos-raspberrypi.lib.nixosSystemFull {inherit (inputs) nixos-raspberrypi;};
in {
  flake.nixosConfigurations = {
    canterbury = mkDefaultHost ./canterbury/configuration.nix;
    rocinante = mkDefaultHost ./rocinante/configuration.nix;
    tycho = mkRpiHost ./tycho/configuration.nix;
  };
}
