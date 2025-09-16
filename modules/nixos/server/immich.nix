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

    lockedVersion = mkOption {
      type = types.str;
      description = "Locked version of Immich";
      default = "1.142.0";
    };

    package = mkPackageOption pkgs "immich" {};
  };

  config = let
    cfg = config.custom.server;
    cfgi = cfg.immich;
  in
    lib.mkIf cfgi.enable {
      assertions = lib.singleton {
        assertion = cfgi.package.version == cfgi.lockedVersion;
        message = ''
          Immich is v${cfgi.package.version}, but expected v${cfgi.lockedVersion}.

          Please check for breaking changes before updating the locked version.

          https://github.com/immich-app/immich/releases
        '';
      };

      custom.server = let
        host = {
          proxyPort = cfg.ports.tcp.immich;
          webSockets = true;
        };
      in {
        immich.dataDir = lib.mkDefault "${cfg.data.baseDirectory}/immich";
        postgresql.enable = true; # Immich depends on this
        subdomains.${cfgi.subdomain} = host;
        # TODO: We can only have one local root as *.local doesn't support
        # subdomains. Serving DNS would allow us to have multiple
        # Assigning Immich for now as it benefits greatly from not needing a
        # round trip via Cloudflare
        localRoot = host;

        homepage.services = lib.singleton rec {
          group = "Media";
          name = "Immich";
          description = "Photo library";
          href = "https://${cfgi.subdomain}.${cfg.hostname}";
          icon = "immich.svg";
          widget = {
            type = "immich";
            config = {
              url = href;
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
        # Disable the obsolete pgvecto.rs extension, which I have migrated
        # from manually.
        database.enableVectors = false;

        # TODO: Hardware transcoding
        # accelerationDevices = [???];
      };
    };
}
