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
    ...
  }@inputs:
  let
    # Function to create a user for a host
    mk-user = {
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

      home-manager.users.${userName} = {
        imports = [
          ./modules/home
          ./users/${userName}.nix
        ];

        # Home Manager needs a bit of information about you and the paths it should
        # manage.
        home.username = userName;
        home.homeDirectory = "/home/${userName}";
      };
    };

    mk-kk-user = system: let
      pkgs = import nixpkgs { system = system; allowUnfree = true; };
    in mk-user {
      userName = "kieran";
      displayName = "Kieran";
      isSudoer = true;
      shell = pkgs.nushell;
    };
  in rec {
    lib = import ./lib { inherit nixpkgs nixpkgs-unstable self inputs; };

    nixosConfigurations = {
      desktop = lib.host.mkHost {
        name = "desktop";
        system = "x86_64-linux";
        users = [
          (mk-kk-user "x86_64-linux")
        ];
      };
      laptop = lib.host.mkHost {
        name = "laptop";
        system = "x86_64-linux";
        users = [
          (mk-kk-user "x86_64-linux")
        ];
      };
    };
  };
}
