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
    # Function to create a user for a host
    mk-user = {
      hostName, # Host name # TODO: Make a "users" folder instead and remove home.nix from the hosts
      userName, # Login name
      displayName, # Name shown in UIs
      isSudoer ? false, # Whether the user should be able to sudo
      shell, # Package for the user's shell
    }: {
      users.users.${userName} = {
        # A regular user that can log in
        isNormalUser = true; # A regular user that can log in
        # User's full name
        description = displayName;

        # Give everyone "networkmanager" membership so they can connect to networks
        # Give sudoers "wheel" membership so they can sudo
        extraGroups = [ "networkmanager" ]
          ++ (if isSudoer then [ "wheel" ] else []);

        shell = shell;
      };

      home-manager.users.${userName} = import ./hosts/${hostName}/home.nix { userName = userName; };
    };

    # Function to create a host configuration
    # Imports ./hosts/$host/configuration.nix
    mk-host = {
      name, # Host name. Should match the key in nixosConfigurations for rebuilds to detect it automatically
      system, # System type. Usually x86_64-linux
      users, # A list of users to create, as returned by mk-user
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
          # Base home-manager for all users
          # TODO: Move this to a module
          home-manager = {
            useGlobalPkgs = true;
            # Pass all flake inputs to home manager configs
            extraSpecialArgs = { inherit inputs system pkgs-unstable; };
            backupFileExtension = "backup";
          };
        }
      ] ++ users;
    };

    pkgs-linux64 = import nixpkgs { system = "x86_64-linux"; allowUnfree = true; };
  in {
    nixosConfigurations = {
      desktop = mk-host {
        name = "desktop";
        system = "x86_64-linux";
        users = [
          (mk-user {
            hostName = "desktop";
            userName = "kieran";
            displayName = "Kieran";
            isSudoer = true;
            shell = pkgs-linux64.nushell;
          })
        ];
      };
    };
  };
}
