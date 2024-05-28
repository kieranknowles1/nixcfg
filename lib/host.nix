{ nixpkgs, nixpkgs-unstable, flake, inputs }:
{
  # Function to create a host configuration
  # Imports ./hosts/$host/configuration.nix
  mkHost = {
    name, # Host name. Should match the key in nixosConfigurations for rebuilds to detect it automatically
    system, # System type. Usually x86_64-linux
    users, # A list of users to create, as returned by mk-user
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
      ({pkgs, ...}:{
        # Base nixos for all hosts
        networking.hostName = name; # The hostname is used as the default target of nixos-rebuild switch

        environment.systemPackages = with pkgs; [
          home-manager
        ];

        # Base home-manager for all users
        home-manager = {
          useGlobalPkgs = true;
          # Pass all flake inputs to home manager configs
          extraSpecialArgs = moduleArgs;
          backupFileExtension = "backup";
        };
      })
    ] ++ users;
  };
}
