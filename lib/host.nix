{
  nixpkgs,
  nixpkgs-unstable,
  flake,
  inputs,
}: {
  /*
  *
  Create a host configuration. It imports the host's configuration.nix and hardware-configuration.nix files.
  from the hosts/${host} directory, as well as the modules/nixos and modules/home-manager directories.

  All configuration should be done in the host's configuration.nix file, which is available
  to home-manager as `hostConfig`.

  # Arguments

  rootConfig :: Path : The path to the root `configuration.nix` file, which is responsible for setting everything else.

  rootConfig.nix format:
  ```nix
  {
    system = system_type # e.g. "x86_64-linux"

    config = {pkgs, ...}: {
      # A Nix module that configures the system
    }
  }
  ```
  */
  mkHost = rootConfig: let
    config = import rootConfig;
    system = config.system;
    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
  in nixpkgs.lib.nixosSystem {
    # Pass the flake's inputs and pkgs-unstable to the module
    # TODO: Import more packages here, and remove the scattered imports in modules
    specialArgs = {inherit flake inputs pkgs-unstable;};

    # Include the host's configuration and all modules
    modules = [
      # We need to import flake inputs here, otherwise we'll get infinite recursion
      flake.nixosModules.default
      inputs.home-manager.nixosModules.home-manager
      inputs.sops-nix.nixosModules.sops
      inputs.stylix.nixosModules.stylix
      config.config
      {
        nixpkgs.hostPlatform = system;
      }
    ];
  };
}
