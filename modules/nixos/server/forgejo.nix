{
  config,
  lib,
  ...
}: {
  options.custom.server.forgejo = let
    inherit (lib) mkOption mkEnableOption types;
  in {
    enable = mkEnableOption "Forgejo Git server";

    subdomain = mkOption {
      type = types.str;
      default = "git";
      description = "The subdomain for Forgejo.";
    };

    dataDir = mkOption {
      type = types.path;
      description = "The directory where Forgejo will store its data.";
    };
  };

  config = let
    cfg = config.custom.server;
    cfgf = cfg.forgejo;
  in
    lib.mkIf cfgf.enable {
      custom.server = {
        forgejo.dataDir = "${cfg.data.baseDirectory}/forgejo";
        subdomains.${cfgf.subdomain} = {
          # Bit confusing, HTTP_ADDR refers to a socket path when using unix sockets
          proxySocket = config.services.forgejo.settings.server.HTTP_ADDR;
        };
      };

      services.forgejo = {
        enable = true;

        settings = {
          server = {
            ROOT_URL = "https://${cfgf.subdomain}.${cfg.hostname}";
            PROTOCOL = "http+unix";
          };

          service = {
            # This is not a public service
            DISABLE_REGISTRATION = true;
          };

          database = {
            SQLITE_JOURNAL_MODE = "WAL";
          };
        };

        # No need to complicate things
        database.type = "sqlite3";
      };
    };
}
