{
  description = "The NixOS configuration for my systems";

  inputs = {
    # /// Core ///
    nixpkgs-stable.url = "github:nixos/nixpkgs?ref=nixos-24.05";
    # This isn't quite the bleeding edge, but packages on master are not always cached
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager?ref=master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
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
      inputs.nixpkgs.follows = "nixpkgs";

      inputs.flake-compat.follows = "flake-compat";
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
      url = "github:nix-community/nix-vscode-extensions";
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

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # /// Applications ///
    nixvim = {
      url = "github:nix-community/nixvim";
      # NOTE: Nixvim master requires nixpkgs-unstable and will not work with nixpkgs-24.05
      inputs.nixpkgs.follows = "nixpkgs";
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
      # Keep this locked to avoid rebuilding whenever libs are updated
      inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=759537f06e6999e141588ff1c9be7f3a5c060106";

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
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    flake-utils-plus = {
      url = "github:gytis-ivaskevicius/flake-utils-plus";
      inputs.flake-utils.follows = "flake-utils";
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

    # TODO: Could be useful for updating package inputs
    # nix-update = {
    #   url = "github:lilyinstarlight/nix-update";
    #   inputs.nixpkgs.follows = "nixpkgs";
    #   inputs.flake-parts.follows = "flake-parts";
    #   inputs.treefmt-nix.follows = "treefmt-nix";
    # };
  };

  outputs = {
    self,
    nixpkgs,
    flake-parts,
    ...
  } @ inputs: let
    lib = import ./lib inputs;

    # TODO: Replace all this with flake-parts
    old =
      inputs.flake-utils.lib.eachDefaultSystem (system: let
        importNixpkgs = branch:
          import branch {
            inherit system;
            overlays = builtins.attrValues self.overlays;
          };

        pkgs = importNixpkgs nixpkgs;
      in {
        devShells = import ./shells {
          inherit pkgs;
        };
      })
      // {
        inherit lib; # Expose our lib module to the rest of the flake

        # Extend nixpkgs with flake-specific overlays, for this
        # flake and its dependencies
        overlays = import ./overlays.nix self;

        templates.default = {
          path = ./template;
          description = "A Nix flake with access to this flake's packages, utilities, and lib module";
        };
      };
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = import inputs.systems;

      flake = old;

      imports = [
        ./hosts
        ./modules
        ./packages
        # Format all file types in this flake and others
        # TODO: Automate running this as a check
        inputs.treefmt-nix.flakeModule
        ./treefmt.nix
      ];
    };
}
