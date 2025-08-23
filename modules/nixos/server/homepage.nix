{
  config,
  lib,
  ...
}: {
  options.custom.server.homepage = let
    inherit (lib) mkOption mkEnableOption types;

    widgetType = types.submodule {
      options = {
      };
    };
  in {
    enable = mkEnableOption "gethomepage";
    subdomain = mkOption {
      type = types.str;
      default = "home";
      description = "The subdomain for gethomepage";
    };

    widgets = mkOption {
      type = types.listOf widgetType;
      default = [];
      description = "List of widgets to display on the homepage";
    };
  };

  config = let
    cfg = config.custom.server;
    cfgh = cfg.homepage;
  in
    lib.mkIf cfgh.enable {
      custom.server.subdomains.${cfgh.subdomain} = {
        proxyPort = config.services.homepage-dashboard.listenPort;
      };

      services.homepage-dashboard = {
        enable = true;
        listenPort = cfg.ports.tcp.homepage;
        allowedHosts = "${cfgh.subdomain}.${cfg.hostname}";

        widgets = [
          {
            datetime = {
              locale = "en-GB"; # Day-month-year is objectively wrong
              format = {
                dateStyle = "medium";
                timeStyle = "short";
              };
            };
          }
          {
            resources = {
              label = "System";
              cpu = true;
              memory = true;
              cputemp = true;
              tempmin = 0;
              tempmax = 100;
              units = "metric";
              refresh = 5000;
              network = true;
            };
          }
          {
            resources = {
              label = "Internal";
              disk = "/";
            };
          }
          {
            resources = {
              label = "External";
              disk = "/mnt/extern";
            };
          }
        ];
      };
    };
}
