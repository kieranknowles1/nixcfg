{
  config,
  lib,
  pkgs,
  ...
}: {
  options.custom.server.trilium = let
    inherit (lib) mkOption mkEnableOption mkPackageOption types;
  in {
    enable = mkEnableOption "Trilium server";

    subdomain = mkOption {
      type = types.str;
      description = "Subdomain for Trilium server";
      default = "notes";
    };

    dataDir = mkOption {
      type = types.path;
      description = "Path to the Trilium data directory";
    };

    autoExport = {
      enable = mkEnableOption "auto export Trilium data to Git.";

      package = mkPackageOption pkgs.flake "export-notes" {};

      remote = mkOption {
        type = types.str;
        description = ''
          URL for remote export. Only localhost over SSH is supported.
          This is also not declarative in the slightest. Manually add the key
          to Forgejo's authorized keys, ideally on behalf of a bot user.

          NOTE: Username will likely not be the standard `git`, but rather
          `forgejo`.
        '';
        example = "ssh://forgejo@localhost/user/export.git";
      };

      systemUser = mkOption {
        type = types.str;
        description = "Name of system user for exports";
        default = "trilium-exporter";
      };

      token = mkOption {
        type = types.str;
        description = "Secret Trilium ETAPI token for authentication";
        default = "trilium/export-token";
      };
      sshKey = mkOption {
        type = types.str;
        description = "Secret SSH private key for authentication";
        default = "trilium/ssh-key";
      };

      user = {
        remoteName = mkOption {
          type = types.str;
          description = "Name of bot user to push commits as.";
          default = "export-bot";
        };
        name = mkOption {
          type = types.str;
          description = "Name to associate with commits";
          # This can be anything I want, just like the email. Be silly
          default = "Exportus Automatus";
          example = "Dave";
        };
        email = mkOption {
          type = types.str;
          description = "Email to associate with commits";
          default = "export@${config.custom.server.hostname}";
          defaultText = "export@$${config.custom.server.hostname}";
          example = "dave@example.com";
        };
      };
      schedule = mkOption {
        type = types.str;
        description = ''
          Schedule for automatic exports, expressed as a
          [systemd OnCalendar](https://www.freedesktop.org/software/systemd/man/systemd.time.html#Calendar%20Events)
        '';
        # Run at 11pm instead of midnight so this completes well in time for the night's backup
        default = "23:00:00";
      };
    };

    package = mkPackageOption pkgs "trilium-next-server" {};
  };

  config = let
    cfg = config.custom.server;
    cfgt = cfg.trilium;
    cfge = cfgt.autoExport;
  in
    lib.mkMerge [
      (lib.mkIf cfgt.enable {
        custom.server = {
          trilium.dataDir = lib.mkDefault "${cfg.data.baseDirectory}/trilium";
          subdomains.${cfgt.subdomain} = {
            proxyPort = cfg.ports.tcp.trilium;
            webSockets = true;
          };

          homepage.services = lib.singleton rec {
            group = "Documents";
            name = "Trilium";
            description = "Personal knowledge base";
            icon = "triliumnext.svg";
            href = "https://${cfgt.subdomain}.${cfg.hostname}";
            widget = {
              type = "trilium";
              config = {
                url = href;
                fields = ["notesCount" "dbSize"];
              };
              secrets = {
                key = {
                  id = "TRILIUM_ETAPI_TOKEN";
                  value = cfge.token;
                };
              };
            };
          };
        };

        services.trilium-server = {
          enable = true;
          port = cfg.ports.tcp.trilium;
          inherit (cfgt) dataDir package;

          nginx.enable = false; # We handle this ourselves
        };
      })
      (
        lib.mkIf (cfgt.enable && cfge.enable) {
          sops.secrets = {
            "trilium-export/token" = {
              key = cfge.token;
              owner = cfge.systemUser;
            };
            "trilium-export/sshKey" = {
              key = cfge.sshKey;
              owner = cfge.systemUser;
            };
          };

          users.users.${cfge.systemUser} = {
            group = cfge.systemUser;
            isSystemUser = true;
            createHome = true;
            home = "/var/lib/${cfge.systemUser}";
          };
          users.groups.${cfge.systemUser} = {};

          custom.timer."export-trilium" = let
            finalExporter = cfge.package.override {
              apiRoot = "http://localhost:${builtins.toString cfg.ports.tcp.trilium}/etapi";
              apiKeyFile = config.sops.secrets."trilium-export/token".path;
              destinationDir = "${config.users.users.${cfge.systemUser}.home}/export-staging";
            };

            app = pkgs.writeShellApplication {
              name = "export-trilium-job";
              runtimeInputs = [pkgs.git pkgs.openssh finalExporter];
              runtimeEnv = {
                EMAIL = cfge.user.email;
                NAME = cfge.user.name;
                REPO = cfge.remote;
                SSH_KEY = config.sops.secrets."trilium-export/sshKey".path;
              };
              text = ''
                stageDir="$HOME/export-staging"
                if [ ! -d "$stageDir" ]; then
                  # First-time setup, init a git repo and find localhost's fingerprint
                  mkdir -p "$stageDir"
                  cd "$stageDir"
                  git init
                  git remote add origin "$REPO"

                  # We can trust localhost, add its fingerprint
                  mkdir -p ~/.ssh
                  ssh-keyscan localhost >> ~/.ssh/known_hosts
                fi
                cd "$stageDir"
                # Make sure all config is up-to-date
                ln --symbolic --force "$SSH_KEY" ~/.ssh/id_ed25519
                ssh-keygen -y -f ~/.ssh/id_ed25519 > ~/.ssh/id_ed25519.pub
                echo "Attempting to push with public key $(cat ~/.ssh/id_ed25519.pub)"
                git config user.email "$EMAIL"
                git config user.name "$NAME"
                git config push.autoSetupRemote true
                git remote set-url origin "$REPO"

                # Here's where the magic happens. The prior arcane rituals
                # make sure that Git can push in the export-notes script
                export-notes
              '';
            };
          in {
            inherit (cfge) schedule;
            user = cfge.systemUser;
            description = "Export Trilium notes";
            command = "${app}/bin/${app.name}";
            persistent = false;
            # /tmp will contain a zip of all notes
            privateTmp = true;
          };
        }
      )
    ];
}
