{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-23.11";

    home-manager = {
      url = "github:nix-community/home-manager?ref=release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;

      config = {
        allowUnfree = true;
      };
    };
    in
    {

    nixosConfigurations = {
      desktop = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs system; };

        modules = [
          ./nixos/configuration.nix
        ];
      };
    };
  };
}

