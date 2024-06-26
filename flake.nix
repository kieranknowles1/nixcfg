{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=master";

    home-manager = {
      url = "github:nix-community/home-manager?ref=master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # We want to be on the latest versions here
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons&ref=master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Again, we want to be on the latest versions
    # This is a much more complete set of extensions than the ones in nixpkgs
    vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions?ref=master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    ...
  }@inputs:
  let
    # The default branch to use for nixpkgs. Individual packages can request
    # the unstable branch by referencing `pkgs-unstable` instead of `pkgs`.
    # If we're feeling brave, we can point everything at unstable.
    defaultNixpkgs = nixpkgs-unstable;

    lib = import ./lib {
      inherit nixpkgs-unstable inputs;
      nixpkgs = defaultNixpkgs;
      flake = self;
    };

    mk-kk-user = system: let
      pkgs = import defaultNixpkgs { system = system; allowUnfree = true; };
    in lib.user.mkUser {
      userName = "kieran";
      displayName = "Kieran";
      isSudoer = true;
      shell = pkgs.nushell;
    };
  in rec {
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

    # Formatter for all Nix files in this flake. Run using `nix fmt`.
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;

    packages.x86_64-linux = import ./packages {
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      flakeLib = lib;
    };

    devShells.x86_64-linux = import ./shells {
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      flakeLib = lib;
      flakePkgs = packages.x86_64-linux;
    };
  };
}
