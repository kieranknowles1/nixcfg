{
  nixpkgs,
  nixpkgs-unstable,
  flake,
  inputs,
}: {
  # TODO: Do this automatically for everything in ./hosts and put all options in the host's configuration.nix
  /*
  *
  Create a host configuration. It imports the host's configuration.nix and hardware-configuration.nix files.
  from the hosts/${host} directory, as well as the modules/nixos and modules/home-manager directories.

  All configuration should be done in the host's configuration.nix file, which is available
  to home-manager as `hostConfig`.

  # Arguments
  name :: String : The host name. Should match the key in nixosConfigurations for rebuilds to detect it automatically

  system :: String : System type. Usually x86_64-linux

  users :: List : A list of users to create, as returned by [lib.mkUser](#function-library-lib.user.mkUser)
  */
  mkHost = {
    name,
    system,
  }: let
    pkgs-unstable = import nixpkgs-unstable {
      system = system;
      config.allowUnfree = true;
    };

    # The "specialArgs" are available to all of a module's imports
    moduleArgs = {inherit flake inputs system pkgs-unstable;};
  in
    nixpkgs.lib.nixosSystem {
      # Pass the flake's inputs and the system type to the module
      specialArgs = moduleArgs;

      # Include the host's configuration and all modules
      # The host configuration.nix can configure the modules
      modules = [
        inputs.stylix.nixosModules.stylix
        # TODO: Why does importing home-manager in a module not work? Why does it need to be imported here?
        inputs.home-manager.nixosModules.home-manager
        ../modules/nixos
        ../hosts/${name}/configuration.nix
        ../hosts/${name}/hardware-configuration.nix
        ({
          pkgs,
          config,
          ...
        }: {
          # Base nixos for all hosts
          networking.hostName = name; # The hostname is used as the default target of nixos-rebuild switch

          nixpkgs.hostPlatform = system;
        })
      ];
    };
}
