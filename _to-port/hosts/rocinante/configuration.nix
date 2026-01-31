# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  pkgs,
  config,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  custom = {
    users = {
      users.kieran = import ../../users/kieran {inherit pkgs config;};
      sharedConfig.custom = {
        games.enable = true;
        desktop.modbright.enable = true;
      };
    };

    networking.hostName = "rocinante";
    repoPath = "/home/kieran/Documents/src/nixcfg";

    secrets = {
      ageKeyFile = "/home/kieran/.config/sops/age/keys.txt";
      file = ./secrets.yaml;
    };

    ledState.enable = true;
    vr.enable = true;

    desktop = {
      enable = true;
      environment = "gnome";
    };

    hardware = {
      memorySize = 32;
      nvidia.enable = true;
    };

    compat = {
      appimage.enable = true;
    };

    backup.repositories.documents = {
      password = "backup/password";
      owner = "kieran";
      source = "/home/kieran/Documents";
      # Exclude .git and src, as these are already tracked by git
      exclude = [".git" "src"];
      destination.local = "/home/kieran/Backups/Documents";
      destination.remote = "backup/remote";
    };
  };
}
