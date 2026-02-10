{
  imports = [
    ./assets.nix
    ./builders
    ./checks
    ./hosts
    ./lib
    ./modules
    ./packages
    ./shells
    # Extend nixpkgs with flake-specific overlays, for this
    # flake and its dependencies
    ./overlays
    # Format all file types in this flake and others
    ./treefmt.nix
  ];
}
