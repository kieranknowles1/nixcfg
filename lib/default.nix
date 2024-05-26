{
  nixpkgs,
  nixpkgs-unstable,
  flake, # The `self` parameter of the flake. We use this instead of `self` to make it clear where the value comes from. Same for any host configuration.
  inputs,
}:
{
  host = import ./host.nix { inherit nixpkgs nixpkgs-unstable flake inputs; };
  image = import ./image.nix { inherit nixpkgs; };
  user = import ./user.nix {};
}
