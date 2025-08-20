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
      default = "1.136.0";
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

        # TODO: Hardware transcoding
        # accelerationDevices = [???];
      };
    };
}
