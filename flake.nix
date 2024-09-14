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
      inputs.flake-utils.follows = "flake-utils";
      inputs.home-manager.follows = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";

      inputs.flake-compat.follows = "flake-compat";
    };

    # TODO: Use the official Cosmic once https://github.com/NixOS/nixpkgs/pull/330167 is merged
    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs.nixpkgs-stable.follows = "nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs-unstable";

      inputs.flake-compat.follows = "flake-compat";
      inputs.nix-update.follows = "nix-update";
    };

    # Prebuilt nix-index database, as building it takes a long time
    # Updates every week
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
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

      inputs.flake-compat.follows = "flake-compat";
    };

    # /// Utilities ///

    # Used to generate schemas for config files. This lets a JSON/YAML/TOML/whatever the next format is
    # language server provide completions, type checking, and documentation by linking to the schema.
    # We prefer TOML as it allows comments and has a nix-like syntax, but YAML could have its uses.
    # See [[./lib/docs.nix]] for more information. This is a much more convenient way to find options than generated markdown.
    # TODO: Could use more of this to provision servers
    clan-core = {
      url = "git+https://git.clan.lol/clan/clan-core";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.sops-nix.follows = "sops-nix";
      inputs.systems.follows = "systems";

      inputs.flake-parts.follows = "flake-parts";
      inputs.treefmt-nix.follows = "treefmt-nix";
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

      inputs.flake-parts.follows = "flake-parts";
      inputs.flake-compat.follows = "flake-compat";
      inputs.treefmt-nix.follows = "treefmt-nix";
      inputs.nuschtosSearch.follows = "nuschtosSearch";
    };

    # nixpkgs doesn't include the dependencies for master, so we override a separate flake
    # The source code could also be a flake input, but doing so would take a long time to update
    # TODO: Remove this once 0.48 is building on nixpkgs
    openmw = {
      url = "git+https://codeberg.org/PopeRigby/openmw-nix.git";
      inputs.nixpkgs.follows = "nixpkgs";

      inputs.snowfall-lib.follows = "snowfall-lib";
    };

    # Using flake inputs for source lets us be on master without needing to manually update
    # hashes.
    src-factorio-blueprint-decoder = {
      # Branch name is a bit misleading, it represents the original repo with all
      # PRs merged in. I use it so I have the latest without waiting for the PR
      url = "github:kieranknowles1/factorio-blueprint-decoder?ref=turret_fix";
      flake = false;
    };

    # /// Unused Libraries ///
    # These are libraries that aren't used in the flake, but are included to avoid
    # duplicating inputs of other inputs.
    # TODO: See if we can detect if any of these are unnecessary and warn/error,
    # could also check for duplicate inputs in general.
    flake-compat = {
      url = "github:edolstra/flake-compat";
    };

    # TODO: Maybe migrate to this from flake-utils
    # Also look at snowfall-lib and flake-utils-plus
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };

    flake-utils-plus = {
      url = "github:gytis-ivaskevicius/flake-utils-plus";
      inputs.flake-utils.follows = "flake-utils";
    };

    # TODO: This could be useful for formatting Nix, Rust, and any other language that
    # ends up in the flake.
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # TODO: Seems very useful for viewing documentation. Could set it up to cover
    # everything but nixpkgs.
    nuschtosSearch = {
      url = "github:NuschtOS/search";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "flake-compat";
      inputs.flake-utils-plus.follows = "flake-utils-plus";
    };

    nix-update = {
      url = "github:lilyinstarlight/nix-update";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.treefmt-nix.follows = "treefmt-nix";
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
      importNixpkgs = branch:
        import branch {
          inherit system;
          overlays = builtins.attrValues self.overlays;
        };

      pkgs = importNixpkgs nixpkgs;
      pkgs-unstable = importNixpkgs nixpkgs-unstable;
    in {
      # Run this using `nix fmt`. Applied to all .nix files in the flake.
      formatter = pkgs.alejandra;

      # We can't use `callPackage` here as Nix expects all values to be derivations,
      # and callPackage generates functions to override the returned value.
      # We use pkgs-unstable as the OS is running unstable, and this avoids duplication of dependencies.
      packages = import ./packages {
        inherit flake inputs;
        pkgs = pkgs-unstable;
      };

      devShells = import ./shells {
        pkgs = pkgs-unstable;
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

      # Extend nixpkgs with flake-specific overlays, for this
      # flake and its dependencies
      overlays = import ./overlays.nix flake;

      templates.default = {
        path = ./template;
        description = "A Nix flake with access to this flake's packages, utilities, and lib module";
      };
    };
}
