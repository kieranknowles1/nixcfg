{
  nixpkgs,
  self,
  inputs,
  ...
}: {
  flake.lib.host = {
    /*
    Create a host configuration. It imports the host's configuration.nix and hardware-configuration.nix files.
    from the hosts/${host} directory, as well as the modules/nixos and modules/home-manager directories.

    All configuration should be done in the host's configuration.nix file, which is available
    to home-manager as `hostConfig`.
    Note that usage of `hostConfig` should be minimised, as it makes the configuration less portable.

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
    in
      nixpkgs.lib.nixosSystem {
        # Pass the flake's inputs and pkgs-unstable to the module
        # TODO: See if we can remove this entirely, would remove the assumption that we're passing certain arguments
        specialArgs = {inherit self inputs;};

        # Include the host's configuration and all modules
        modules = [
          # We need to import flake inputs here, otherwise we'll get infinite recursion
          # Don't even try debugging, the Nix module system is dark magic
          self.nixosModules.default
          inputs.home-manager.nixosModules.home-manager
          inputs.nix-index-database.nixosModules.nix-index
          inputs.sops-nix.nixosModules.sops
          inputs.stylix.nixosModules.stylix
          # TODO: Remove once Cosmic is merged into Nixpkgs
          inputs.nixos-cosmic.nixosModules.default
          config.config
          {
            nixpkgs.hostPlatform = system;
          }
        ];
      };

    /*
    Read a TOML and format it such that it can be used directly in a module's configuration.

    # Arguments
    path :: Path : The path to the TOML file to read

    # Returns
    A TOML object with the `$schema` key removed
    */
    readTomlFile = path: let
      toml = builtins.fromTOML (builtins.readFile path);
      # TODO: Could maybe convert paths to Nix paths, relative to the toml file
      # but that would require args for:
      # - The directory containing the toml file
      # - The Nix module the config is used in
    in
      builtins.removeAttrs toml ["$schema"];
  };
}
