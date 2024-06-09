{
  nixpkgs,
  nixpkgs-unstable,
  flake, # The `self` parameter of the flake. We use this instead of `self` to make it clear where the value comes from. Same for any host configuration.
  inputs,
}:
{
  docs = import ./docs.nix { inherit nixpkgs; };
  host = import ./host.nix { inherit nixpkgs nixpkgs-unstable flake inputs; };
  image = import ./image.nix { inherit nixpkgs; };
  package = import ./package.nix { inherit nixpkgs; };
  user = import ./user.nix {};
}
