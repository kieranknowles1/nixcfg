{
  config,
  lib,
  ...
}: {
  options.custom.server.grafana = let
    inherit (lib) mkOption mkEnableOption types;
  in {
    enable = mkEnableOption "Grafana dashboard";

    subdomain = mkOption {
      type = types.str;
      default = "dash";
      description = "The subdomain for Grafana";
    };

    dataDir = mkOption {
      type = types.path;
      defaultText = "$${config.custom.server.data.baseDirectory}/grafana";
      description = "The directory where Grafana stores its data";
    };
  };

  config = let
    cfg = config.custom.server;
    cfgg = cfg.grafana;
  in
    lib.mkIf cfgg.enable {
      custom.server = {
        grafana.dataDir = "${cfg.data.baseDirectory}/grafana";

        subdomains.${cfgg.subdomain} = {
          proxySocket = config.services.grafana.settings.server.socket;
        };
      };

      services.grafana = {
        inherit (cfgg) dataDir;
        enable = true;

        settings = {
          analytics = {
            check_for_plugin_updates = false;
            check_for_updates = false;
            reporting_enabled = false;
          };

          server = {
            protocol = "socket";
            # Give nginx access to the socket
            socket_mode = "0666";
          };

          database = {
            type = "sqlite3";
            wal = true;
          };
        };
      };
    };
}
