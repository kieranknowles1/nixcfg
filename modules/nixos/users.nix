{
  pkgs,
  config,
  flake,
  inputs,
  system,
  pkgs-unstable,
  ...
}: {
  # TODO: Replace mkUser with this, that way
  # we can have other options depend on it
  # mkHost's home-manager can also be handled here

  config = {
    environment.systemPackages = with pkgs; [
      home-manager
    ];

    home-manager = {
      # Inherit the global pkgs
      useGlobalPkgs = true;

      # Pass flake inputs plus host configuration
      # TODO: The system arg seems redundant, can we use config.??? instead?
      extraSpecialArgs = {
        inherit flake inputs system pkgs-unstable;
        hostConfig = config;
      };

      # If a file to be provisioned already exists, back it up
      backupFileExtension = "backup";
    };
  };
}
