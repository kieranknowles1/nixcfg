{
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

    rootConfig :: Module : The root configuration module for the host. This can be any Nix module, usually the path
    to the host's configuration.nix file.
    ```
    */
    mkHost = mkSystem: extraSpecialArgs: rootConfig:
      mkSystem {
        # Pass the flake's inputs to the module
        specialArgs = {inherit self inputs;} // extraSpecialArgs;

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
          rootConfig
        ];
      };

    /*
    Read a TOML and format it such that it can be used directly in a module's configuration.
    Paths are not supported. Nix expressions are preferred to configure more complex modules.

    # Arguments
    path :: Path : The path to the TOML file to read

    # Returns
    A TOML object with the `$schema` key removed
    */
    readTomlFile = path: let
      toml = builtins.fromTOML (builtins.readFile path);
    in
      builtins.removeAttrs toml ["$schema"];
  };
}
