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

  rootConfig :: Path : The path to the root `configuration.nix` file, which will be imported and is responsible for
  applying all host-specific configuration.

  system :: String : System type. Usually x86_64-linux
  */
  mkHost = {
    rootConfig,
    system, # TODO: Remove this. Last usage is currently the pkgs-unstable import
  }: let
    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
  in
    nixpkgs.lib.nixosSystem {
      # Pass the flake's inputs and the system type to the module
      specialArgs = {inherit flake inputs pkgs-unstable;};

      # Include the host's configuration and all modules
      # The host configuration.nix can configure the modules
      modules = [
        inputs.stylix.nixosModules.stylix
        # TODO: Why does importing home-manager in a module not work? Why does it need to be imported here?
        inputs.home-manager.nixosModules.home-manager
        flake.nixosModules.default
        rootConfig
      ];
    };
}
