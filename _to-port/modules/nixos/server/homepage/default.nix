{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./glances.nix
  ];

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
          type = types.nullOr types.str;
          example = "Personal Knowledge Base";
          description = ''
            A brief description of the widget. Aim for 3 words or less.
          '';
        };
        icon = mkOption {
          type = types.nullOr types.str;
          example = "fa-solid fa-folder";
          description = ''
            The icon to display for the widget.
            See [homepage docs](https://gethomepage.dev/configs/services/#icons)

            Most services are available from [Dashboard Icons](https://dashboardicons.com/).
            Simply pass the name of the icon, preferably in SVG format.
          '';
        };
        href = mkOption {
          type = types.nullOr types.str;
          example = "https://example.com";
          description = ''
            The URL to which the widget should link. If null, the widget will
            not be clickable.
          '';
        };

        widget = {
          # TODO: This is a bit redundant and could go under config
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
          description = "Number of columns per row if using the `row` style";
        };
        useEqualHeights = mkOption {
          type = types.bool;
          default = false;
          description = "Use equal heights for items in the group";
        };
        sortOrder = mkOption {
          type = types.int;
          default = 0;
          description = ''
            Sort order of the group, higher numbers are displayed last.
            Matching groups will be sorted alphabetically.
          '';
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
      description = ''
        List of services to display on the homepage.

        All services that define a subdomain MUST also define a service here for
        quick access.
      '';
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
      warnings = lib.optional (!cfg.adguard.enable) ''
        You have enabled homepage without AdGuard, service widgets will not function
        as they rely on AdGuard to resolve *.hostname.local addresses.
      '';

      custom.server = {
        homepage.groups = let
          # Like a DAG, but less confusing
          sort = rec {
            first = default - 100;
            default = 0;
            last = default + 100;
          };
        in rec {
          Documents.icon = "mdi-folder-open";
          Games.icon = "mdi-controller";
          Media.icon = "mdi-camera";
          Meta.icon = "mdi-information-variant-circle";
          Metrics = {
            icon = "mdi-chart-line";
            sortOrder = Infrastructure.sortOrder - 1;
            style = "row";
            # 4 columns, and we have 8 metrics. How convenient that it isn't
            # prime!
            columns = 4;
            useEqualHeights = true;
          };
          Infrastructure = {
            icon = "mdi-server";
            style = "row";
            columns = 2;
            sortOrder = sort.last;
          };
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
          # Don't want this to be publicly exposed (at least on the internet, LAN is fine)
          # But there's nothing sensitive enough to warrant two-factor authentication.
          authorization = {
            policy = "one_factor";
            subject = ["group:admins"];
          };
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

        customJS = builtins.readFile ./custom.js;
        settings = {
          language = "en-GB";
          theme = "dark";
          color = "slate";

          layout = let
            pairs = lib.attrsets.mapAttrsToList (name: value: {inherit name value;}) cfgh.groups;

            sortPredicate = a: b:
              if a.value.sortOrder != b.value.sortOrder
              then a.value.sortOrder < b.value.sortOrder
              else a.name < b.name;
          in
            map (kv: {${kv.name} = kv.value;}) (builtins.sort sortPredicate pairs);
        };

        widgets = let
          glancesUrl = "http://localhost:${builtins.toString cfg.ports.tcp.glances}";
        in [
          # Top bar. This displays as the following:
          # Desktop - Uptime, search, weather, time
          # Mobile - Uptime \n search, weather \n time
          # Unfortunately, I don't see a way to force weather and time to be
          # on the same row on mobile, so it looks a bit ugly
          {
            glances = {
              url = glancesUrl;
              version = 4;
              cpu = false;
              mem = false;
              cputemp = false;
              uptime = true;
            };
          }
          {
            search = {
              provider = "duckduckgo";
              # Can still type to search, services will be prioritized
              focus = false;
              showSearchSuggestions = true;
              # Open in current tab
              target = "_self";
            };
          }
          {
            openmeteo = {
              latitude = 54.97;
              longitude = -1.61;
              timezone = "Europe/London";
              units = "metric";
              cache = 5; # Avoid making too many requests
              format.maximumFractionalDigits = 1;
            };
          }
          {
            datetime = {
              format = {
                dateStyle = "medium";
                timeStyle = "short";
              };
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
