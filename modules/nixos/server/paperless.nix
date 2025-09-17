{
  config,
  lib,
  ...
}: {
  options.custom.server.paperless = let
    inherit (lib) mkOption mkEnableOption types;
  in {
    enable = mkEnableOption "Paperless";
    subdomain = mkOption {
      type = types.str;
      default = "papers";
      description = "The subdomain for Paperless";
    };
    dataDir = mkOption {
      type = types.path;
      defaultText = "$${config.custom.server.data.baseDirectory}/paperless";
      description = "The directory where Paperless will store its data";
    };
  };

  config = let
    cfg = config.custom.server;
    cfgp = cfg.paperless;
  in
    lib.mkIf cfgp.enable {
      custom.server = {
        paperless.dataDir = "${cfg.data.baseDirectory}/paperless";
        subdomains.${cfgp.subdomain} = {
          proxyPort = cfg.ports.tcp.paperless;
        };

        postgresql.enable = true;

        homepage.services = lib.singleton rec {
          group = "Documents";
          name = "Paperless";
          description = "Document management system";
          icon = "paperless-ngx.svg";
          href = "https://${cfgp.subdomain}.${cfg.hostname}";
          # TODO: This isn't working currently
          # widget = {
          #   type = "paperlessngx";
          #   config.url = href;
          #   secrets.token = {
          #     id = "PAPERELESS_TOKEN";
          #     value = "paperless/token";
          #   };
          # };
        };
      };

      services.paperless = {
        inherit (cfgp) dataDir;
        enable = true;
        port = cfg.ports.tcp.paperless;

        # Use PostgreSQL as the database backend
        database.createLocally = true;

        settings = {
          PAPERLESS_URL = "https://${cfgp.subdomain}.${cfg.hostname}";
          # Allow Nginx to proxy to us
          PAPERLESS_TRUSTED_PROXIES = "127.0.0.1";

          PAPERLESS_OCR_LANGUAGE = "eng";
          # Attempt to remove scanner artifacts
          PAPERLESS_OCR_CLEAN = "clean";

          # TODO: Name files in the format "$user_$document"
        };
      };
    };
}
