{ nixpkgs, nixpkgs-unstable, self, inputs, ... }:
{
  host = import ./host.nix { inherit nixpkgs nixpkgs-unstable self inputs; };
}
