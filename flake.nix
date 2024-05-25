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
    lib = import ./lib { inherit nixpkgs nixpkgs-unstable self inputs; };

    mk-kk-user = system: let
      pkgs = import nixpkgs { system = system; allowUnfree = true; };
    in lib.user.mkUser {
      userName = "kieran";
      displayName = "Kieran";
      isSudoer = true;
      shell = pkgs.nushell;
    };
  in {
    inherit lib; # Extend the lib with our custom functions

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
