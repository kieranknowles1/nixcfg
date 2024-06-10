{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=master";

    home-manager = {
      url = "github:nix-community/home-manager?ref=release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      # We want to be on the latest versions here
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons&ref=master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Again, we want to be on the latest versions
    # This is a much more complete set of extensions than the ones in nixpkgs
    vscode-extensions.url = "github:nix-community/nix-vscode-extensions?ref=master";

    # TODO: Pin this to 24.05 once it releases on stable
    stylix.url = "github:danth/stylix?ref=master";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    ...
  }@inputs:
  let
    lib = import ./lib {
      inherit nixpkgs nixpkgs-unstable inputs;
      flake = self;
    };

    mk-kk-user = system: let
      pkgs = import nixpkgs { system = system; allowUnfree = true; };
    in lib.user.mkUser {
      userName = "kieran";
      displayName = "Kieran";
      isSudoer = true;
      shell = pkgs.nushell;
    };
  in {
    inherit lib; # Expose the lib module to configurations

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

    packages.x86_64-linux = import ./packages {
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      flakeLib = lib;
    };
  };
}
