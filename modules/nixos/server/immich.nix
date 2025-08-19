{
  config,
  lib,
  pkgs,
  ...
}: {
  options.custom.server.immich = let
    inherit (lib) mkOption mkEnableOption mkPackageOption types;
  in {
    enable = mkEnableOption "Immich";

    subdomain = mkOption {
      type = types.str;
      description = "Subdomain for Immich";
      default = "photos";
    };

    dataDir = mkOption {
      type = types.path;
      description = "Path to the Immich data directory";
    };

    package = mkPackageOption pkgs "immich" {};
  };

  config = let
    cfg = config.custom.server;
    cfgi = cfg.immich;
  in
    lib.mkIf cfgi.enable {
      custom.server = {
        immich.dataDir = lib.mkDefault "${cfg.data.baseDirectory}/immich";
        postgresql.enable = true; # Immich depends on this
        subdomains.${cfgi.subdomain} = {
          proxyPort = cfg.ports.tcp.immich;
          webSockets = true;
        };
      };

      # Workaround for https://github.com/nixos/nixpkgs/issues/418799
      # needed for machine-learning to download models
      users.users.immich = {
        home = "/var/lib/immich";
        createHome = true;
      };

      services.immich = {
        enable = true;
        port = cfg.ports.tcp.immich;
        mediaLocation = cfgi.dataDir;

        database.port = cfg.ports.tcp.postgresql;

        # Give the GPU for hardware transcoding
        accelerationDevices = [
          "/dev/dri/renderD128"
        ];
      };
    };
}
