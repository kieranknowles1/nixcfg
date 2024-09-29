{
  description = "A flake based on my NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    systems.url = "github:nix-systems/default-linux";

    flake-parts.url = "github:hercules-ci/flake-parts";

    nixcfg = {
      url = "github:kieranknowles1/nixcfg";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
  };

  outputs = {
    flake-parts,
    nixcfg,
    ...
  } @ inputs: let
    cfgLib = nixcfg.lib;
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = import inputs.systems;

      flake = {
        # Shared across all systems

        # Inherit formatters from nixcfg
        formatter = nixcfg.formatter;
      };

      perSystem = {pkgs, ...}: {
        # Per system type
        devShells = {
          # Wrapper that sets the magic DEVSHELL variable, and preserves the user's default shell
          # Usage: `nix develop [.#name=default]`
          default = cfgLib.shell.mkShellEx {
            name = "dev";
            packages = with pkgs; [
              hello
            ];

            shellHook = ''
              echo "Hello, world!"
            '';
          };
        };

        packages = {
          # Usage: `nix run [.#name=default]`
          default = pkgs.hello;
        };
      };
    };
}
