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

        homepage.services = lib.singleton {
          group = "Media";
          name = "Immich";
          description = "Photo library";
          href = "https://${cfgi.subdomain}.${cfg.hostname}";
          icon = "immich.svg";
          widget = {
            type = "immich";
            config = {
              url = "http://${cfgi.subdomain}.${config.networking.hostName}.local";
              version = 2; # Server version >= 1.118
            };
            secrets.key = {
              id = "IMMICH_API_KEY";
              # Requires the `server.statistics` permission.
              value = "immich/api-key";
            };
          };
        };
      };

      custom.backup.defaultExclusions = [
        # These are derived from source photos/videos. Excluding them
        # saves ~5% space.
        "immich/thumbs"
        "immich/encoded-video"
      ];

      services.immich = {
        enable = true;
        port = cfg.ports.tcp.immich;
        mediaLocation = cfgi.dataDir;

        database.port = cfg.ports.tcp.postgresql;
        # Disable the obsolete pgvecto.rs extension, which I have migrated
        # from manually.
        database.enableVectors = false;

        # TODO: Hardware transcoding
        # accelerationDevices = [???];
      };
    };
}
