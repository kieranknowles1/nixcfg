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
      
      sops.templates."vikunja-oidc.env"= {
        content = ''
          VIKUNJA_AUTH_OPENID_PROVIDERS_DEFAULT_CLIENTSECRET=${config.sops.placeholder."vikunja/oidc-secret"}
        '';
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
            
            # service:
              # Enable the caldav endpoint, see the docs for more details
              # enablecaldav: true
              # Enable sharing of project via a link
              # enablelinksharing: true
              # Whether to enable task attachments or not
              # enabletaskattachments: true
              # Whether totp is enabled. In most cases you want to leave that enabled.
              # enabletotp: true
          };
          # 
          # cors:
            # Whether to enable or disable cors headers.
            # By default, this is enabled only for requests from the desktop application running on localhost.
            # Note: If you want to put the frontend and the api on separate domains or ports, you will need to adjust this setting accordingly.
            # enable: true
            # A list of origins which may access the api. These need to include the protocol (`http://` or `https://`) and port, if any.
            # origins:
              # - "http://127.0.0.1:*"
              # - "http://localhost:*"
            # How long (in seconds) the results of a preflight request can be cached.
            # maxage: 0
            
          mailer = {
            
          # mailer:
            # Whether to enable the mailer or not. If it is disabled, all users are enabled right away and password reset is not possible.
            # enabled: false
            # SMTP Host
            # host: ""
            # SMTP Host port.
            # **NOTE:** If you're unable to send mail and the only error you see in the logs is an `EOF`, try setting the port to `25`.
            # port: 587
            # SMTP Auth Type. Can be either `plain`, `login` or `cram-md5`.
            # authtype: "plain"
            # SMTP username
            # username: "user"
            # SMTP password
            # password: ""
            # Whether to skip verification of the tls certificate on the server
            # skiptlsverify: false
            # The default from address when sending emails
            # fromemail: "mail@vikunja"
            # The length of the mail queue.
            # queuelength: 100
            # The timeout in seconds after which the current open connection to the mailserver will be closed.
            # queuetimeout: 30
            # By default, Vikunja will try to connect with starttls, use this option to force it to use ssl.
            # forcessl: false
          # 
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
              };
            };
            # OpenID configuration will allow users to authenticate through a third-party OpenID Connect compatible provider.<br/>
            # The provider needs to support the `openid`, `profile` and `email` scopes.<br/>
            # **Note:** Some openid providers (like Gitlab) only make the email of the user available through OpenID if they have set it to be publicly visible.
            # If the email is not public in those cases, authenticating will fail.<br/>
            # **Note 2:** The frontend expects the third party to redirect the user <frontend-url>/auth/openid/<auth key> after authentication. Please make sure to configure the redirect url in your third party auth service accordingly if you're using the default Vikunja frontend.
            # The frontend will automatically provide the API with the redirect url, composed from the current url where it's hosted.
            # If you want to use the desktop client with OpenID, make sure to allow redirects to `127.0.0.1`.
            # openid:
              # Enable or disable OpenID Connect authentication
              # enabled: false
              # A list of enabled providers. You can freely choose the `<provider key>`. Note that you must add at least one key to a config file if you want to read values from an environment variable as the provider won't be known to Vikunja otherwise.
              # providers:
                # -
                # <provider key>:
                  # The scope necessary to use oidc.
                  # If you want to use the Feature to create and assign to Vikunja teams via oidc, you have to add the custom "vikunja_scope" and check [openid.md](https://vikunja.io/docs/openid/).
                  # e.g. scope: openid email profile vikunja_scope
                  # scope: "openid email profile"
                  # This option forces the use of the OpenID Connect UserInfo endpoint to retrieve user information instead of relying on claims from the ID token. When set to `true`, user data (email, name, username) will always be obtained from the UserInfo endpoint even if the information is available in the token claims. This is useful for providers that don't include complete user information in their tokens or when you need the most up-to-date user data. Allowed value is either `true` or `false`.
                  # forceuserinfo: false
                  # This option requires the OpenID Connect provider to be available during Vikunja startup. When set to `true`, Vikunja will crash if it cannot connect to the provider during initialization, allowing container orchestrators like Kubernetes to handle the failure by restarting the application. This is useful in environments where you want to ensure all authentication providers are available before the application starts serving requests. Allowed value is either `true` or `false`.
                  # requireavailability: false
                # 
          };
          
          defaultsettings = {
            week_start = 1; # Weeks start on Monday
            email_reminders_enabled = true;
            overdue_tasks_reminders_enabled = true;
            discoverable_by_name = true; # Allow searching by name
          };
          # webhooks:
            # Whether to enable support for webhooks
            # enabled: true
            # The timeout in seconds until a webhook request fails when no response has been received.
            # timeoutseconds: 30
            # Deprecated: use outgoingrequests.proxyurl instead. The URL of [a mole instance](https://github.com/frain-dev/mole) to use to proxy outgoing webhook requests. You should use this and configure appropriately if you're not the only one using your Vikunja instance. More info about why: https://webhooks.fyi/best-practices/webhook-providers#implement-security-on-egress-communication. Must be used in combination with `webhooks.password` (see below).
            # proxyurl: ""
            # Deprecated: use outgoingrequests.proxypassword instead. The proxy password to use when authenticating against the proxy.
            # proxypassword: ""
            # Deprecated: use outgoingrequests.allownonroutableips instead. If set to true, webhook target URLs may resolve to non-globally-routable IP addresses (private networks, loopback, link-local, etc). When false (the default), Vikunja blocks outgoing webhook requests to these addresses to prevent SSRF attacks. Set this to true if you need webhooks to reach services on your internal network.
            # allownonroutableips: false
          
          # outgoingrequests:
            # If set to true, outgoing HTTP requests (webhooks, avatar downloads, migration imports) may resolve to non-globally-routable IP addresses. When false (the default), Vikunja blocks these to prevent SSRF attacks. Set to true only if you need these to reach services on your internal network.
            # allownonroutableips: false
            # The URL of [a mole instance](https://github.com/frain-dev/mole) to use to proxy outgoing HTTP requests. Applies to webhooks, avatar downloads, and migration imports. You should use this and configure appropriately if you're not the only one using your Vikunja instance. More info about why: https://webhooks.fyi/best-practices/webhook-providers#implement-security-on-egress-communication. Must be used in combination with `outgoingrequests.proxypassword`.
            # proxyurl: ""
            # The proxy password for authenticating against the proxy.
            # proxypassword: ""
          
          # TODO
        };

        environmentFiles = lib.singleton config.sops.templates."vikunja-oidc.env".path;
      };
    };
}
