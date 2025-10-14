{
  description = "The NixOS configuration for my systems";

  # Dependencies for the flake
  # The syntax `inputs.xxx.follows = ""` removes the input from another flake, this is useful
  # when the input is unused by us to avoid fetching unnecessary data. (I believe flake inputs
  # are lazily fetched, but I'd rather be explicit)
  inputs = {
    # /// Core ///
    # This isn't quite the bleeding edge, but packages on master are less likely to be cached
    # Use a fork as required by nixos-raspberrypi until https://github.com/NixOS/nixpkgs/pull/398456
    # is merged
    nixpkgs.url = "github:kieranknowles1/nixpkgs?ref=nixpkgs-unstable-readd-option";

    home-manager = {
      url = "github:nix-community/home-manager?ref=master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.flake-parts.follows = "flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";

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

    nixos-raspberrypi = {
      url = "github:nvmd/nixos-raspberrypi";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.argononed.follows = "";
      inputs.nixos-images.follows = "";
    };

    # Run a fixed kernel to avoid needing to build it
    nixos-raspberrypi-kernellock = {
      url = "github:nvmd/nixos-raspberrypi?ref=27518152d10345308bc5340fd64c8d3ad5c88c92";
      inputs.nixpkgs.url = "github:nvmd/nixpkgs?ref=1cba0d4e9720ce8cd0e6b08ff185b92646fe2f90";
      inputs.argononed.follows = "";
      inputs.nixos-images.follows = "";
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
    copyparty = {
      url = "github:9001/copyparty";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";

      inputs.flake-compat.follows = "";
    };

    # Using flake inputs for source lets us be on master without needing to manually update
    # hashes.
    src-openmw = {
      url = "gitlab:kieranjohn1/openmw";
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

    nuschtosSearch = {
      url = "github:NuschtOS/search";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.ixx.follows = "ixx";
    };
    ixx = {
      url = "github:NuschtOS/ixx";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
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
        ./assets.nix
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
