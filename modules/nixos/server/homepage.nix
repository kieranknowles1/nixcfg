{
  config,
  lib,
  pkgs,
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
            The ID of the secret. Must be unique. It is therefore recommended
            to prefix with the service name to avoid conflicts.
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

        widget = {
          type = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = "trilium";
            description = ''
              The type of widget to display.
              See [homepage docs](https://gethomepage.dev/widgets/)
            '';
          };

          config = mkOption {
            type = types.attrsOf types.anything;
            default = {};
            example = {
              url = "https://docs.example.com";
              fields = ["fields" "to" "display"];
            };
            description = ''
              Config for the widget.
            '';
          };

          secrets = mkOption {
            type = types.attrsOf secretType;
            default = {};
            example = {
              apiKey = {
                id = "MY_API_KEY";
                value = "sops/to/key";
              };
            };
            description = ''
              Secrets for the widget.
            '';
          };
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

    neededSecrets =
      lib.lists.flatten
      (map (srv: builtins.attrValues srv.widget.secrets) cfgh.services);
  in
    lib.mkIf cfgh.enable {
      custom.server.subdomains.${cfgh.subdomain} = {
        proxyPort = config.services.homepage-dashboard.listenPort;
      };

      sops.secrets = builtins.listToAttrs (map (secret: {
          name = "homepage/${secret.id}";
          value = {
            key = secret.value;
            # FIXME: homepage uses a dynamic user, how do we
            # assign it to own a secret?
            # owner = "homepage-dashboard";
            mode = "0444";
          };
        })
        neededSecrets);

      # TODO: This exposes some things more than I'd like. Should
      # place it behind auth
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

        environmentFile = let
          toEnv = secret: "HOMEPAGE_FILE_${secret.id}=${config.sops.secrets."homepage/${secret.id}".path}";
        in
          builtins.toString (pkgs.writeText "homepage.env"
            (builtins.concatStringsSep "\n" (
              builtins.map toEnv neededSecrets
            )));

        services = let
          groups = builtins.groupBy (s: s.group) cfgh.services;
          secretFileRef = sec: "{{HOMEPAGE_FILE_${sec.id}}}";

          toHome = srv: {
            ${srv.name} = {
              inherit (srv) description icon href;

              # Widget requests are proxied through homepage. A preliminary
              # check of the source code showed that arbritary endpoint access
              # is not allowed. Still don't fully trust this, so want to put the
              # service behind authentication.

              # Using mkIf instead of optionalAttrs so that, if no widget is
              # defined, the widget attribute will be omitted rather than set to
              # an empty object.
              widget = lib.mkIf (srv.widget.type != null) (lib.mkMerge [
                {
                  inherit (srv.widget) type;
                }
                srv.widget.config
                (builtins.mapAttrs (_name: secretFileRef) srv.widget.secrets)
              ]);
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
