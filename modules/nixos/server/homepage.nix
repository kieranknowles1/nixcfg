{
  config,
  lib,
  ...
}: {
  options.custom.server.homepage = let
    inherit (lib) mkOption mkEnableOption types;

    secretType = types.submodule {
      options = {
        id = mkOption {
          type = types.str;
          example = "MY_API_KEY";
          description = ''
            The ID of the secret. Must be unique.
          '';
        };
        value = mkOption {
          type = types.str;
          example = "sops/to/value";
          description = ''
            The source of the secret in sops.yaml.
          '';
        };
      };
    };

    serviceType = types.submodule {
      options = {
        group = mkOption {
          type = types.str;
          example = "Documents";
          description = ''
            The group name to which the widget belongs.
          '';
        };
        name = mkOption {
          type = types.str;
          example = "My Documents";
          description = ''
            The name of the widget.
          '';
        };
        description = mkOption {
          type = types.str;
          example = "My personal documents";
          description = ''
            A brief description of the widget.
          '';
        };
        icon = mkOption {
          type = types.str;
          example = "fa-solid fa-folder";
          description = ''
            The icon to display for the widget.
            See [homepage docs](https://gethomepage.dev/configs/services/#icons)

            Most services are available from [Dashboard Icons](https://dashboardicons.com/).
            Simply pass the name of the icon, preferably in SVG format.
          '';
        };
        href = mkOption {
          type = types.str;
          example = "https://example.com";
          description = ''
            The URL to which the widget should link.
          '';
        };

        widgetType = mkOption {
          type = types.str;
          example = "trilium";
          description = ''
            The type of widget to display.
            See [homepage docs](https://gethomepage.dev/widgets/)
          '';
        };
        widgetConfig = mkOption {
          type = types.attrsOf types.str;
          example = {
            url = "https://docs.example.com";
          };
          description = ''
            Config for the widget.
          '';
        };
        widgetSecrets = mkOption {
          type = types.attrsOf secretType;
          example = {
            apiKey = {
              id = "MY_API_KEY";
              value = "sops/to/value";
            };
          };
          description = ''
            Secrets for the widget. Provisioned by SOPS.
          '';
        };
      };
    };
  in {
    enable = mkEnableOption "gethomepage";
    subdomain = mkOption {
      type = types.str;
      default = "home";
      description = "The subdomain for gethomepage";
    };

    services = mkOption {
      type = types.listOf serviceType;
      default = [];
      description = "List of services to display on the homepage";
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

        services = let
          groups = builtins.groupBy (s: s.group) cfgh.services;

          toHome = s: {
            ${s.name} = {
              inherit (s) description icon href;
            };
          };

          mappedGroups =
            lib.attrsets.mapAttrsToList (name: grp: {
              ${name} = map toHome grp;
            })
            groups;
        in
          mappedGroups;
      };
    };
}
