{
  description = "A flake based on my NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    systems.url = "github:nix-systems/default-linux";

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    nixcfg = {
      url = "github:kieranknowles1/nixcfg";
      inputs.nixpkgs-unstable.follows = "nixpkgs";
      inputs.systems.follows = "systems";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    eachDefaultSystem = inputs.flake-utils.lib.eachDefaultSystem;
    cfgLib = inputs.nixcfg.lib;
  in
    eachDefaultSystem (system: let
      pkgs = import inputs.nixpkgs {inherit system;};
    in {
      # Per system type
      packages = {
      };

      devShells = {
        # Wrapper that sets the magic DEVSHELL variable, and preserves the user's default shell
        default = cfgLib.shell.mkShellEx {
          name = "dev";
          packages = with pkgs; [
            hello
          ];

          shellHook = ''
            hello
          '';
        };
      };
    })
    // {
      # Shared across all systems

      # Format all files the same way as in the nixcfg repo via treefmt
      formatter = inputs.nixcfg.formatter;
    };
}
