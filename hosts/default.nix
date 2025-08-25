{
  self,
  inputs,
  ...
}: let
  inherit (self.lib.host) mkHost;
  mkDefaultHost = mkHost inputs.nixpkgs.lib.nixosSystem {};
  mkRpiHost = mkHost inputs.nixos-raspberrypi.lib.nixosSystem {inherit (inputs) nixos-raspberrypi;};
in {
  canterbury = mkDefaultHost ./canterbury/configuration.nix;
  rocinante = mkDefaultHost ./rocinante/configuration.nix;
  tycho = mkRpiHost ./tycho/configuration.nix;
}
