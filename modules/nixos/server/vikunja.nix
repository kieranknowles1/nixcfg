{
  config,
  lib,
  ...
}: {
  options.custom.server.vikunja = let
    inherit (lib) mkOption mkEnableOption types;
  in {
    enable = mkEnableOption "Vikunja";

    subdomain = mkOption {
      type = types.str;
      default = "todos";
      description = "The subdomain for Vikunja";
    };

    dataDir = mkOption {
      type = types.path;
      defaultText = "$${config.custom.server.data.baseDirectory}/vikunja";
      description = "The direction where Vikunja will store its data";
    };
  };

  config = let
    cfg = config.custom.server;
    cfgv = cfg.vikunja;
  in
    lib.mkIf cfgv.enable {
      custom.server = {
        subdomains.${cfgv.subdomain} = {
          proxyPort = config.services.vikunja.port;
        };

        vikunja.dataDir = "${cfg.data.baseDirectory}/vikunja";

        authelia.oidcClients.vikunja = {
          name = "Vikunja";
          secretHash = "$pbkdf2-sha512$310000$YTHBYV61tvYswg.XB.gG3A$ZvMFjQf3TE9kMTgYRwvWLxp3eT4cZKTaczuU3LkzKdlaZA3qv90YctBcRwO5lpSVx2guNDRfS13fOZW9HL4.iA";
          redirects = [
            "https://${cfgv.subdomain}.${cfg.hostname}/auth/openid/default"
          ];
        };

        # TODO: Homepage widget
        # https://gethomepage.dev/widgets/services/vikunja/
      };

      systemd.services.vikunja.serviceConfig = {
        # Required for ownership of attachments and secrets
        DynamicUser = lib.mkForce false;
        User = "vikunja";
        Group = "vikunja";
        ReadWritePaths = [cfgv.dataDir];
      };
      users.groups.vikunja = {};
      users.users.vikunja = {
        isSystemUser = true;
        group = "vikunja";
      };

      sops.secrets."vikunja/oidc-secret" = {
        key = "vikunja/oidc-secret";
        owner = "vikunja";
      };
      sops.secrets."vikunja/smtp-password" = {
        key = "authelia/smtp/password";
        owner = "vikunja";
      };

      custom.mkdir.${cfgv.dataDir} = {
        user = "vikunja";
        group = "vikunja";
      };

      services.postgresql = {
        ensureUsers = lib.singleton {
          name = "vikunja";
          ensureDBOwnership = true;
        };
        ensureDatabases = ["vikunja"];
      };

      services.vikunja = {
        enable = true;
        port = cfg.ports.tcp.vikunja;

        database = {
          type = "postgres";
          host = "/run/postgresql/";
        };

        frontendScheme = "https";
        frontendHostname = "${cfgv.subdomain}.${cfg.hostname}";

        settings = {
          service = {
            enableregistration = false;
            enableuserdeletion = false;
            timezone = config.time.timeZone;
            ipextrctionmethod = "xff"; # X-Forwarded-For header
            trustedproxies = "127.0.0.1/32"; # Only trust proxies from localhost
            enablecaldav = true; # Sync to third-party calanders, read/write access
          };

          mailer = {
            enabled = true;
            # TODO: Pull in username, endpoint, and password from terraform
            host = "email-smtp.eu-north-1.amazonaws.com";
            inherit (cfg.authelia.smtp) username;
            password.file = config.sops.secrets."vikunja/smtp-password".path;
            fromemail = "todos@selwonk.uk";
          };

          files = {
            # Default from NixPkgs
            basepath = lib.mkForce cfgv.dataDir;
          };

          auth = {
            local.enabled = false;

            openid = {
              enabled = true;
              providers.default = {
                name = "Authelia";
                authurl = "https://${cfg.authelia.subdomain}.${cfg.hostname}";
                clientid = "vikunja";
                clientsecret.file = config.sops.secrets."vikunja/oidc-secret".path;
              };
            };
          };

          defaultsettings = {
            week_start = 1; # Weeks start on Monday
            email_reminders_enabled = true;
            overdue_tasks_reminders_enabled = true;
            discoverable_by_name = true; # Allow searching by name
          };

          webhooks.enabled = false;
        };
      };
    };
}
