# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  pkgs,
  config,
  nixos-raspberrypi,
  ...
}: {
  imports = with nixos-raspberrypi.nixosModules; [
    ./hardware-configuration.nix
    # Base support
    raspberry-pi-5.base
    # Display support (may be unnecessary since we are a server)
    raspberry-pi-5.display-vc4
    # Avoid issues from jemalloc expecting a hardcoded page size
    raspberry-pi-5.page-size-16k
  ];

  # Enable everything needed for this configuration
  custom = {
    users = {
      users.kieran = import ../../users/kieran {inherit pkgs config;};
    };

    repoPath = "/home/kieran/src/nixcfg";
    hardware = {
      memorySize = 8;
      raspberryPi.enable = true;
    };

    # Takes over a minute on almost every rebuild.
    docs.generateManCache = false;
    docs-generate.baseUrl = "https://github.com/kieranknowles1/nixcfg/blob/master";

    networking = {
      hostName = "tycho";
      fixedIp = "192.168.1.207";
      waitOnline = true;
    };

    server = {
      enable = true;
      hostname = "selwonk.uk";
      data.baseDirectory = "/mnt/extern/data";

      # Renewal is manual, but I don't really care because certs last 15 years
      # TODO: We should really be automating this and revoke the 15 year one
      ssl = {
        publicKeyFile = ./selwonk.uk.pem;
        privateKeySecret = "ssl/private-key";
      };

      root = {
        root = pkgs.flake.portfolio;
        cache.enable = true;
      };

      actual.enable = true;
      adguard.enable = true;
      docs.enable = true;
      forgejo.enable = true;
      homepage.enable = true;
      immich.enable = true;
      paperless.enable = true;
      # FIXME: This rebuilds the whole webapp on options change, not just the index
      # which takes over a minute whenever options change
      # search.enable = true;

      authelia = {
        enable = true;
        smtp.username = "AKIA4HIUFKO4HYENRIPH";
        smtp.endpoint = "smtp://email-smtp.eu-north-1.amazonaws.com";
      };

      minecraft = {
        enable = true;
        whitelist.kieranknowles1 = "55b348b0-9713-42ca-922f-f2e763296ff0";
      };

      trilium = {
        enable = true;
        autoExport.enable = true;
        autoExport.remote = "ssh://forgejo@localhost/kieran/trilium-export.git";
      };

      copyparty = {
        enable = true;
        users.kieran.passwordSecret = "copyparty/kieran/password";
      };
    };

    backup.repositories.server = {
      source = "/mnt/extern/data";
      password = "backup/password";
      destination.local = "/mnt/extern/restic";
      destination.remote = "backup/remote";

      # Creating btrfs snapshots requires root privileges
      owner = "root";
      btrfs = {
        useSnapshots = true;
        snapshotPath = "/mnt/extern/backup-snapshot";
      };
    };

    secrets = {
      ageKeyFile = "/home/kieran/.config/sops/age/keys.txt";
      file = ./secrets.yaml;
    };
  };
}
