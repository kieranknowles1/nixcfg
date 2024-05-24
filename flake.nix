{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=master";

    home-manager = {
      url = "github:nix-community/home-manager?ref=release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      # We want to be on the latest versions here
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons&ref=master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix.url = "github:danth/stylix?ref=release-23.11";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    stylix,
    ...
  }@inputs:
  let
    # Function to create a host configuration
    # Imports ./hosts/$host/configuration.nix
    mk-host = { name, system }: nixpkgs.lib.nixosSystem {
      specialArgs = {
        # Pass the flake's inputs and the system type to the module
        inherit inputs system;
        hostName = name;

        # Pass the unstable nixpkgs for the host platform
        pkgs-unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };

      # Include the host's configuration
      modules = [
        stylix.nixosModules.stylix
        ./hosts/${name}/configuration.nix
      ];
    };
  in {

    nixosConfigurations = {
      desktop = mk-host {
        name = "desktop";
        system = "x86_64-linux";
      };
    };
  };
}

