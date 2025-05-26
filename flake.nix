{
  description = "The NixOS configuration for my systems";

  # Dependencies for the flake
  # The syntax `inputs.xxx.follows = ""` removes the input from another flake, this is useful
  # when the input is unused by us to avoid fetching unnecessary data. (I believe flake inputs
  # are lazily fetched, but I'd rather be explicit)
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
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.flake-parts.follows = "flake-parts";
      inputs.home-manager.follows = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";

      inputs.flake-compat.follows = "";
      # Remove some inputs that are not used by this flake
      inputs.base16-fish.follows = "";
      inputs.base16-helix.follows = "";
      inputs.base16-vim.follows = "";
      inputs.tinted-foot.follows = "";
      inputs.tinted-kitty.follows = "";
      inputs.tinted-schemes.follows = "";
      inputs.tinted-tmux.follows = "";
      inputs.tinted-zed.follows = "";
      inputs.nur.follows = "";
    };

    # TODO: Use the official Cosmic once https://github.com/NixOS/nixpkgs/pull/330167 is merged
    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs.nixpkgs-stable.follows = "nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";

      inputs.flake-compat.follows = "";
    };

    # Prebuilt nix-index database, as building it takes a long time
    # Updates every week
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # /// Sub Repositories ///
    # These are repositories not included in this repo due to their size but are needed
    # to build some hosts.
    factorio-blueprints = {
      url = "github:kieranknowles1/factorio-blueprints";
      # Importing as a flake would cause a circular dependency
      flake = false;
    };

    # /// Extensions ///
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons&ref=master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # This is a much more complete set of extensions than the ones in nixpkgs
    vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
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
      inputs.systems.follows = "systems";
      inputs.flake-parts.follows = "flake-parts";
      inputs.treefmt-nix.follows = "treefmt-nix";

      inputs.data-mesher.follows = "";
      inputs.disko.follows = "";
      inputs.sops-nix.follows = "";
      inputs.nixos-facter-modules.follows = "";
      inputs.nix-darwin.follows = "";
    };

    # Generate package sets for x86_64-linux and aarch64-linux. This can be
    # overridden by another flake that consumes this one.
    systems.url = "github:nix-systems/default-linux";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # /// Applications ///

    # nixpkgs doesn't include the dependencies for master, so we override a separate flake
    # The source code could also be a flake input, but doing so would take a long time to update
    # TODO: Remove this once 0.48 is building on nixpkgs
    # Keep this locked to avoid rebuilding whenever libs are updated
    nixpkgs-openmw.url = "github:nixos/nixpkgs?ref=f21e4546e3ede7ae34d12a84602a22246b31f7e0";
    openmw = {
      url = "git+https://codeberg.org/PopeRigby/openmw-nix.git";
      inputs.nixpkgs.follows = "nixpkgs-openmw";

      inputs.snowfall-lib.follows = "snowfall-lib";
    };

    src-openmw = {
      url = "gitlab:kieranjohn1/openmw";
      flake = false;
    };

    # Using flake inputs for source lets us be on master without needing to manually update
    # hashes.
    src-factorio-blueprint-decoder = {
      # Branch name is a bit misleading, it represents the original repo with all
      # PRs merged in. I use it so I have the latest without waiting for the PR
      url = "github:kieranknowles1/factorio-blueprint-decoder?ref=turret_fix";
      flake = false;
    };

    src-tldr = {
      url = "github:tldr-pages/tldr";
      flake = false;
    };

    # /// Unused Libraries ///
    # These are libraries that aren't used in the flake, but are included to avoid
    # duplicating inputs of other inputs.

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    # TODO: Remove once openmw is building on nixpkgs
    flake-utils-plus = {
      url = "github:gytis-ivaskevicius/flake-utils-plus";
      inputs.flake-utils.follows = "flake-utils";
    };

    # TODO: Seems very useful for viewing documentation. Could set it up to cover
    # everything but nixpkgs.
    # nuschtosSearch = {
    #   url = "github:NuschtOS/search";
    #   inputs.nixpkgs.follows = "nixpkgs";
    #   inputs.flake-utils.follows = "flake-utils";
    # };

    # TODO: Remove once openmw is building on nixpkgs
    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils-plus.follows = "flake-utils-plus";

      inputs.flake-compat.follows = "";
    };
  };

  outputs = {flake-parts, ...} @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = import inputs.systems;

      flake = {
        templates.default = {
          path = ./template;
          description = "A Nix flake with access to this flake's packages, utilities, and lib module";
        };
      };

      imports = [
        ./builders
        ./checks
        ./hosts
        ./lib
        ./modules
        ./packages
        ./shells
        # Extend nixpkgs with flake-specific overlays, for this
        # flake and its dependencies
        ./overlays
        # Format all file types in this flake and others
        ./treefmt.nix
      ];
    };
}
