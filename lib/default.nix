{ nixpkgs, nixpkgs-unstable, self, inputs, ... }:
{
  host = import ./host.nix { inherit nixpkgs nixpkgs-unstable self inputs; };
  user = import ./user.nix {};
}
