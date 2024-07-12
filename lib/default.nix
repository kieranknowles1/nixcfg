{
  nixpkgs,
  nixpkgs-unstable,
  flake, # The `self` parameter of the flake. We use this instead of `self` to make it clear where the value comes from. Same for any host configuration.
  inputs,
}: let
  pkgs = import nixpkgs {system = "x86_64-linux";};
in {
  docs = import ./docs.nix {inherit pkgs flake inputs;};
  # This needs nixpkgs for `nixpkgs.lib.nixosSystem`, which is not available from `pkgs`.
  host = import ./host.nix {inherit nixpkgs nixpkgs-unstable flake inputs;};
  image = import ./image.nix {inherit pkgs;};
  package = import ./package.nix {inherit pkgs;};
  shell = import ./shell.nix {inherit pkgs;};
}
