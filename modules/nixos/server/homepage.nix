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

    groupType = types.submodule {
      options = {
        style = mkOption {
          type = types.enum ["column" "row"];
          default = "column";
          description = "Display group items as a column or row layout";
        };
        columns = mkOption {
          type = types.int;
          default = 4;
          description = "Number of columns if using the `column` layout";
        };
        icon = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = ''
            Icon to display for the group, prefixed with `mdi-` for MDI icons.
            See [Material Design Icons](https://pictogrammers.com/library/mdi/)
            for a list of available icons.
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

    groups = mkOption {
      type = types.attrsOf groupType;
      default = {};
      description = "Group configs";
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
      custom.server = {
        homepage.groups = {
          Documents.icon = "mdi-folder-open";
          Media.icon = "mdi-camera";
          Meta.icon = "mdi-information-variant-circle";
        };

        # Widget requests are proxied through homepage. A preliminary
        # check of the source code showed that arbritary endpoint access
        # is not allowed. Still, the high attack surface coupled with somewhat
        # personal information means I want to put the service behind
        # authentication.
        #
        # Trust users on the same LAN, but require authentication for WAN access.
        localRoot.proxyPort = config.services.homepage-dashboard.listenPort;
        subdomains.${cfgh.subdomain} = {
          proxyPort = config.services.homepage-dashboard.listenPort;
          requireAuth = true;
        };
      };

      sops.secrets = builtins.listToAttrs (map (secret: {
          name = "homepage/${secret.id}";
          value = {
            key = secret.value;
            owner = "homepage-dashboard";
          };
        })
        neededSecrets);

      # SOPS can't provision secrets for dynamic users. Use a regular user
      # instead.
      systemd.services.homepage-dashboard.serviceConfig = {
        DynamicUser = lib.mkForce false;
        User = "homepage-dashboard";
        Group = "homepage-dashboard";
      };

      users.groups.homepage-dashboard = {};
      users.users.homepage-dashboard = {
        isSystemUser = true;
        group = "homepage-dashboard";
      };

      services.homepage-dashboard = {
        enable = true;
        listenPort = cfg.ports.tcp.homepage;
        allowedHosts = builtins.concatStringsSep "," [
          "${cfgh.subdomain}.${cfg.hostname}"
          "${cfgh.subdomain}.${config.networking.hostName}.local"
          "${config.networking.hostName}.local"
        ];

        settings = {
          language = "en-GB";
          theme = "dark";
          color = "slate";

          layout = cfgh.groups;
        };

        widgets = [
          {
            datetime = {
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

              # Using mkIf instead of optionalAttrs so that, if no widget is
              # defined, the widget attribute will be omitted rather than set to
              # an empty object, which Homepage would see as an error.
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
