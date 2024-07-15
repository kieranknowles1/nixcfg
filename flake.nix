{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=master";

    # Used to generate schemas for config files. This lets
    # our language server provide completions, type checking, and documentation by linking to the schema.
    # See [[./lib/docs.nix]] for more information. This is a much more convenient way to find options than generated markdown.
    clan-core = {
      url = "git+https://git.clan.lol/clan/clan-core";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

    nixvim = {
      url = "github:nix-community/nixvim?ref=nixos-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
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
  } @ inputs: let
    # The default branch to use for nixpkgs. Individual packages can request
    # the unstable branch by referencing `pkgs-unstable` instead of `pkgs`.
    # If we're feeling brave, we can point everything at unstable.
    defaultNixpkgs = nixpkgs-unstable;

    lib = import ./lib {
      inherit nixpkgs-unstable inputs;
      nixpkgs = defaultNixpkgs;
      flake = self;
    };
  in rec {
    inherit lib; # Expose the lib module to configurations

    nixosConfigurations = {
      desktop = lib.host.mkHost {
        name = "desktop";
        system = "x86_64-linux";
      };
      laptop = lib.host.mkHost {
        name = "laptop";
        system = "x86_64-linux";
      };
      server = lib.host.mkHost {
        name = "server";
        system = "x86_64-linux"; # TODO: Should be arm, but I can't cross-compile directly. Try mounting the flake in a minimal ARM NixOS VM and building it there.
      };
    };

    # Formatter for all Nix files in this flake. Run using `nix fmt`.
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;

    packages.x86_64-linux = import ./packages {
      inherit inputs;
      pkgs = import nixpkgs {system = "x86_64-linux";};
      flakeLib = lib;
    };

    devShells.x86_64-linux = import ./shells {
      pkgs = import nixpkgs {system = "x86_64-linux";};
      flakeLib = lib;
      flakePkgs = packages.x86_64-linux;
    };
  };
}
