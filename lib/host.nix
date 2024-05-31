{ nixpkgs, nixpkgs-unstable, flake, inputs }:
{
  /**
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
    users,
  }: let
    pkgs-unstable = import nixpkgs-unstable { system = system; config.allowUnfree = true; };

    # The "specialArgs" are available to all of a module's imports
    moduleArgs = { inherit flake inputs system pkgs-unstable; };
  in nixpkgs.lib.nixosSystem {
    # Pass the flake's inputs and the system type to the module
    specialArgs = moduleArgs;

    # Include the host's configuration and all modules
    # The host configuration.nix can configure the modules
    modules = [
      inputs.stylix.nixosModules.stylix
      inputs.home-manager.nixosModules.home-manager
      ../modules/nixos
      ../hosts/${name}/configuration.nix
      ../hosts/${name}/hardware-configuration.nix
      ({ pkgs, config, ... }:{
        # Base nixos for all hosts
        networking.hostName = name; # The hostname is used as the default target of nixos-rebuild switch

        environment.systemPackages = with pkgs; [
          home-manager
        ];

        # Base home-manager for all users
        home-manager = {
          useGlobalPkgs = true;
          # Pass all flake inputs to home manager configs
          # Also expose the host's configuration
          extraSpecialArgs = moduleArgs // { hostConfig = config; };
          backupFileExtension = "backup";
        };
      })
    ] ++ users;
  };
}
