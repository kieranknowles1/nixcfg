{
  description = "The NixOS configuration for my systems";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=master";

    # Used to generate schemas for config files. This lets a JSON/YAML/TOML/whatever the next format is
    # language server provide completions, type checking, and documentation by linking to the schema.
    # We prefer TOML as it allows comments and has a nix-like syntax, but YAML could have its uses.
    # See [[./lib/docs.nix]] for more information. This is a much more convenient way to find options than generated markdown.
    clan-core = {
      url = "git+https://git.clan.lol/clan/clan-core";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.sops-nix.follows = "sops-nix";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.nixpkgs-stable.follows = "nixpkgs";
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
      url = "github:nix-community/nixvim";
      # NOTE: Nixvim master requires nixpkgs-unstable and will not work with nixpkgs-24.05
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.home-manager.follows = "home-manager";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # Source code that will updated along with the rest of the flake
    # This saves us from having to manually update hashes
    src-factorio-blueprint-decoder = {
      # Branch name is a bit misleading, it represents the original repo with all
      # PRs merged in. I use it so I have the latest without waiting for the PR
      url = "github:kieranknowles1/factorio-blueprint-decoder?ref=turret_fix";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    ...
  } @ inputs: let
    lib = import ./lib {
      inherit nixpkgs nixpkgs-unstable inputs;
      flake = self;
    };
  in rec {
    inherit lib; # Expose the lib module to configurations

    nixosConfigurations = {
      rocinante = lib.host.mkHost ./hosts/rocinante/configuration.nix;
      canterbury = lib.host.mkHost ./hosts/canterbury/configuration.nix;
      razorback = lib.host.mkHost ./hosts/server/razorback.nix;
    };

    # Formatter for all Nix files in this flake. Run using `nix fmt`.
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;

    packages.x86_64-linux = import ./packages rec {
      inherit inputs;
      pkgs = import nixpkgs-unstable {system = "x86_64-linux";};
      callPackage = pkgs.callPackage;
      flakeLib = lib;
    };

    nixosModules.default = import ./modules/nixos;
    homeManagerModules.default = import ./modules/home;

    devShells.x86_64-linux = import ./shells {
      pkgs = import nixpkgs-unstable {system = "x86_64-linux";};
      flakeLib = lib;
      flakePkgs = packages.x86_64-linux;
    };
  };
}
