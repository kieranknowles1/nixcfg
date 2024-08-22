{
  description = "The NixOS configuration for my systems";

  inputs = {
    # /// Core ///
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=master";

    home-manager = {
      url = "github:nix-community/home-manager?ref=master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # /// Extensions ///
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons&ref=master";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    # This is a much more complete set of extensions than the ones in nixpkgs
    vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions?ref=master";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    # /// Utilities ///

    # Used to generate schemas for config files. This lets a JSON/YAML/TOML/whatever the next format is
    # language server provide completions, type checking, and documentation by linking to the schema.
    # We prefer TOML as it allows comments and has a nix-like syntax, but YAML could have its uses.
    # See [[./lib/docs.nix]] for more information. This is a much more convenient way to find options than generated markdown.
    clan-core = {
      url = "git+https://git.clan.lol/clan/clan-core";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.sops-nix.follows = "sops-nix";
      inputs.systems.follows = "systems";
    };

    # Generate package sets for x86_64-linux and aarch64-linux. This can be
    # overridden by another flake that consumes this one.
    systems.url = "github:nix-systems/default-linux";

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    # /// Applications ///
    nixvim = {
      url = "github:nix-community/nixvim";
      # NOTE: Nixvim master requires nixpkgs-unstable and will not work with nixpkgs-24.05
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.home-manager.follows = "home-manager";
    };

    # nixpkgs doesn't include the dependencies for master, so we override a separate flake
    # The source code could also be a flake input, but doing so would take a long time to update
    openmw = {
      url = "git+https://codeberg.org/PopeRigby/openmw-nix.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Using flake inputs for source lets us be on master without needing to manually update
    # hashes.
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
    flake = self; # More explicit than an argument named `self`
    eachDefaultSystem = inputs.flake-utils.lib.eachDefaultSystem;

    lib = import ./lib {
      inherit nixpkgs nixpkgs-unstable inputs;
      flake = self;
    };
  in
    eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [self.overlays.default];
      };
    in {
      # Run this using `nix fmt`. Applied to all .nix files in the flake.
      formatter = pkgs.alejandra;

      # We can't use `callPackage` here as Nix expects all values to be derivations,
      # and callPackage generates functions to override the returned value.
      packages = import ./packages {
        inherit flake inputs pkgs;
      };

      devShells = import ./shells {
        inherit pkgs;
      };
    })
    // {
      inherit lib; # Expose our lib module to the rest of the flake

      nixosConfigurations = {
        rocinante = lib.host.mkHost ./hosts/rocinante/configuration.nix;
        canterbury = lib.host.mkHost ./hosts/canterbury/configuration.nix;
      };

      nixosModules.default = import ./modules/nixos;
      homeManagerModules.default = import ./modules/home;

      # Extend nixpkgs with our own packages and lib
      # TODO: Replace the *.packages.${system} pattern with overlays
      overlays.default = import ./overlay.nix flake;
    };
}
