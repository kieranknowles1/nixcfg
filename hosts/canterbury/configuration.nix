# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  pkgs,
  config,
  self,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  config.custom = {
    networking.hostName = "canterbury";
    users = {
      users.kieran = import ../../users/kieran {inherit pkgs config self;};
      sharedConfig.custom = {
        office.enable = true;
        trilium-client.enable = true;
      };
    };

    secrets = {
      ageKeyFile = "/home/kieran/.config/sops/age/keys.txt";
      file = ./secrets.yaml;
    };

    repoPath = "/home/kieran/Documents/src/nixcfg";
    printing.enable = true;

    desktop = {
      enable = true;
      environment = "gnome";
    };

    hardware = {
      memorySize = 8;

      powerSave = {
        enable = true;
        batteryOnly = true;
      };
    };

    backup.repositories.documents = {
      password = "backup/password"; # Path to the secret
      owner = "kieran";
      source = "/home/kieran/Documents";
      # Exclude .git and src, as these are already tracked by git
      exclude = [".git" "src"];
      destination.local = "/home/kieran/Backups/Documents"; # Local path
      destination.remote = "backup/remote"; # Path to the secret
    };
  };
}
