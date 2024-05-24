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
    mk-host = {
      name,
      system
    }: let
      pkgs = import nixpkgs { system = system; allowUnfree = true; };
      pkgs-unstable = import nixpkgs-unstable { system = system; config.allowUnfree = true; };
    in nixpkgs.lib.nixosSystem {
      specialArgs = {
        # Pass the flake's inputs and the system type to the module
        inherit inputs system pkgs-unstable;
        hostName = name;
      };

      # Include the host's configuration
      modules = [
        stylix.nixosModules.stylix
        ./hosts/${name}/configuration.nix
        {
            # Define a user account. Don't forget to set a password with ‘passwd’.
            users.users.kieran = {
              isNormalUser = true;
              description = "Kieran";
              extraGroups = [ "networkmanager" "wheel" ];

              # Make Nu our default shell
              shell = pkgs.nushell;
            };

            home-manager = {
              useGlobalPkgs = true;
              # Pass all flake inputs to home manager configs
              extraSpecialArgs = { inherit inputs system pkgs-unstable; };
              backupFileExtension = "backup";
              users.kieran = import ./hosts/desktop/home.nix { userName = "kieran"; };
            };
        }
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

