{
  self,
  inputs,
}: {
  /*
  Create a host configuration. It imports the host's configuration.nix and hardware-configuration.nix files.
  from the hosts/${host} directory, as well as the modules/nixos and modules/home-manager directories.

  All configuration should be done in the host's configuration.nix file, which is available
  to home-manager as `hostConfig`.
  Note that usage of `hostConfig` should be minimised, as it makes the configuration less portable.

  # Arguments

  **mkSystem** :: (Func) : The `nixosSystem` function to use for this host. Usually
  `nixpkgs.lib.nixosSystem`.

  **extraSpecialArgs** :: (Attrs) : Additional `specialArgs` to pass to `mkSystem`.

  **rootConfig** :: (Module) : The root configuration module for the host. This
  can be any Nix module, usually the path to the host's configuration.nix file.
  */
  mkHost = mkSystem: extraSpecialArgs: rootConfig:
    mkSystem {
      # Pass the flake's inputs to the module
      specialArgs = {inherit self inputs;} // extraSpecialArgs;

      # Include the host's configuration and all modules
      modules = [
        inputs.home-manager.nixosModules.home-manager
        inputs.nix-index-database.nixosModules.nix-index
        inputs.sops-nix.nixosModules.sops
        inputs.stylix.nixosModules.stylix
        # TODO: Remove once Cosmic is merged into Nixpkgs
        inputs.nixos-cosmic.nixosModules.default
        inputs.nix-minecraft.nixosModules.minecraft-servers
        inputs.copyparty.nixosModules.default
        rootConfig
        # We need to import flake inputs here, otherwise we'll get infinite recursion
        # Don't even try debugging, the Nix module system is dark magic
        # self.nixosModules.default
      ] ++ (builtins.attrValues self.nixosModules);
    };
}
