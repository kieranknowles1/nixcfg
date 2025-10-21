{
  config,
  lib,
  ...
}: {
  options.custom.server.actual = let
    inherit (lib) mkOption mkEnableOption types;
  in {
    enable = mkEnableOption "Actual Finance";

    subdomain = mkOption {
      type = types.str;
      default = "finance";
      description = "The subdomain for Actual";
    };

    dataDir = mkOption {
      type = types.path;
      defaultText = "$${config.custom.server.data.baseDirectory}/actual";
      description = "The directory where Actual will store its data";
    };
  };

  config = let
    cfg = config.custom.server;
    cfga = cfg.actual;
  in
    lib.mkIf cfga.enable {
      custom.server = {
        subdomains.${cfga.subdomain} = {
          proxyPort = cfg.ports.tcp.actual;
        };

        actual.dataDir = "${cfg.data.baseDirectory}/actual";
      };
      custom.mkdir.${cfga.dataDir} = {
        user = "actual";
        group = "actual";
      };

      systemd.services.actual.serviceConfig = {
        # A dynamic user can't properly own files outside of /var
        DynamicUser = lib.mkForce false;
        User = "actual";
        Group = "actual";
        # Allow Actual to write to its data directory
        # nixpkgs sets ProtectSystem=strict, which mounts most
        # directories read-only. Whitelist only what Actual needs.
        ReadWritePaths = [ cfga.dataDir ];
      };
      users.groups.actual = {};
      users.users.actual = {
        isSystemUser = true;
        group = "actual";
      };

      services.actual = {
        enable = true;
        # See https://actualbudget.org/docs/config/
        settings = rec {
          inherit (cfga) dataDir;

          port = cfg.ports.tcp.actual;

          # SQLite Database directory
          serverFiles = "${dataDir}/server-files";
          # User data
          userFiles = "${dataDir}/user-files";
        };
      };
    };
}
