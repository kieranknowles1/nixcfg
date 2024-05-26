{
  nixpkgs,
  nixpkgs-unstable,
  self,
  inputs,
  ...
}:
{
  host = import ./host.nix { inherit nixpkgs nixpkgs-unstable self inputs; };
  image = import ./image.nix { inherit nixpkgs; };
  user = import ./user.nix {};
}
