{
  config,
  lib,
  ...
}: {
  options.custom.server.authelia = let
    inherit (lib) mkOption mkEnableOption types;

    clientType = types.submodule {
      options = {
        name = mkOption {
          type = types.str;
          description = "The client's human-readable name.";
        };
        secretHash = mkOption {
          type = types.str;
          description = ''
            Hash of the client's secret. The associated secret should be stored
            separately in SOPS and visible to the client only.

            Generate a secret using the following command:
            ```sh
            authelia crypto rand --length 72 --charset rfc3986
            ```
          '';
        };
        redirects = mkOption {
          type = types.listOf types.str;
          example = ["https://example.com/oidc/callback"];
          description = "List of redirect URIs for the client. MUST be HTTPS.";
        };
      };
    };

    mkSecret = format: default: name:
      mkOption {
        inherit default;
        type = types.str;
        description = ''
          SOPS path to Authelia's ${name} secret. Should be ${format}.
        '';
      };
    mkAlphaSecret = mkSecret "at least 64 random characters";
  in {
    enable = mkEnableOption "Authelia";

    subdomain = mkOption {
      type = types.str;
      default = "auth";
      description = "The subdomain for Authelia.";
    };

    dataDir = mkOption {
      type = types.path;
      defaultText = "$${config.custom.server.data.baseDirectory}/authelia";
      description = "The directory where Authelia will store its data";
    };

    oidcClients = mkOption {
      type = types.attrsOf clientType;
      description = "List of OIDC clients for Authelia. Each service should be a client";
    };

    jwtSecret = mkAlphaSecret "authelia/jwt-secret" "JWT";
    storageKeySecret = mkAlphaSecret "authelia/storage-key" "Storage Key";
    hmacSecret = mkAlphaSecret "authelia/hmac-secret" "HMAC";
    jwkRsaSecret = mkSecret "a RSA private key. The public key is not required" "authelia/jwk-rsa-secret" "RSA private key";
    smtp = {
      username = mkOption {
        type = types.str;
        example = "my-smtp-user";
        description = "SMTP username";
      };
      # NOT mkAlphaSecret as, at least for AWS, these are set by Amazon SES and not user-defined
      password = mkSecret "SMTP password" "authelia/smtp/password" "SMTP password";
      endpoint = mkOption {
        type = types.str;
        example = "smtp://example.com";
        description = "SMTP endpoint";
      };
    };

    socket = mkOption {
      type = types.str;
      example = "/run/authelia/authelia.sock";
      description = "Socket path for Authelia";
      readOnly = true;
    };
  };

  config = let
    cfg = config.custom.server;
    cfga = cfg.authelia;

    socketDir = "/run/authelia";
    socket = "${socketDir}/authelia.sock";
  in
    lib.mkIf cfga.enable {
      custom.server = {
        subdomains.${cfga.subdomain} = {
          proxySocket = socket;
        };

        homepage.services = lib.singleton {
          group = "Infrastructure";
          name = "Authelia";
          description = "Single Sign-On";
          icon = "authelia.svg";
          href = "https://${cfga.subdomain}.${cfg.hostname}";
        };

        authelia.dataDir = lib.mkDefault "${cfg.data.baseDirectory}/authelia";
        authelia.socket = socket;
      };
      custom.mkdir = {
        ${socketDir} = {
          user = "authelia-default";
          group = "authelia-default";
          # Nginx needs access
          mode = "0755";
        };
        ${cfga.dataDir} = {
          user = "authelia-default";
          group = "authelia-default";
        };
      };

      sops.secrets = let
        secret = key: {
          inherit key;
          owner = "authelia-default";
        };
      in {
        "authelia/jwt-secret" = secret cfga.jwtSecret;
        "authelia/storage-key" = secret cfga.storageKeySecret;
        "authelia/oidc-hmac-secret" = secret cfga.hmacSecret;
        "authelia/jwk-rsa-secret" = secret cfga.jwkRsaSecret;

        "authelia/smtp/password" = secret cfga.smtp.password;
      };

      services.postgresql = {
        ensureUsers = [
          {
            name = "authelia-default";
            ensureDBOwnership = true;
          }
        ];
        ensureDatabases = ["authelia-default"];
      };

      systemd.services.authelia-default.serviceConfig = {
        # Allow Authelia to write to its data directory
        # nixpkgs sets ProtectSystem=strict, which mounts most
        # directories read-only. Whitelist only what Authelia needs.
        ReadWritePaths = [cfga.dataDir];
      };

      services.authelia.instances.default = {
        enable = true;

        settings = {
          # Respect the user's preference as any good app should *cough* Google *cough*
          theme = "auto";

          server = {
            # TODO: Limit access to nginx via group
            address = "unix://${socket}?umask=0111";

            # Provide an endpoint for Nginx to authenticate requests
            endpoints.authz.auth-request = {
              implementation = "AuthRequest";
            };
          };

          # Temporarily block an IP if it appears to be attempting a brute force attack
          regulation = {
            modes = ["ip"];
            # 3 failed attempts within 2 minutes results in a 5 minute ban, effectively
            # limits the attacker to 1.5 attempts per minute without affecting legitimate
            # users too much.
            max_retries = 3;
            find_time = "2 minutes";
            ban_time = "5 minutes";
          };

          log = {
            level = "debug";
            format = "json";
            # Use the systemd journal
            file_path = null;
          };

          storage.postgres = {
            address = "unix:///run/postgresql/.s.PGSQL.5432";
            username = "authelia-default";
            database = "authelia-default";
          };

          authentication_backend = {
            # File-based authentication is less scalable than LDAP, but LDAP would
            # be overkill for my system which I don't expect to grow more than
            # ~10 users.
            file = {
              path = "${cfga.dataDir}/users_database.yaml";

              # Reload the database when something changes
              watch = true;

              # Leave password hashing at the recommended defaults
              # password = {???}
            };
          };

          # Ensure that system time is accurate enough to validate TOTP codes.
          ntp = {
            address = "udp://time.cloudflare.com:123";
            version = 4;
          };

          session = {
            cookies = lib.singleton {
              domain = cfg.hostname;
              authelia_url = "https://${cfga.subdomain}.${cfg.hostname}";
            };
          };

          # Access control rules. These DO NOT apply to OpenID Connect services
          # such as Actualbudget, and are only applied if the endpoint has
          # authorization enabled
          access_control = {
            default_policy = "deny";
            rules = let
              domainsWithAuth = lib.filterAttrs (_k: d: d.authorization.policy != "none") cfg.subdomains;
            in
              lib.mapAttrsToList (subdomain: value: {
                inherit (value.authorization) policy;
                subject = lib.mkIf (value.authorization.subject != null) value.authorization.subject;
                domain = [
                  "${subdomain}.${cfg.hostname}"
                  "${subdomain}.${config.networking.hostName}.local"
                ];
              })
              domainsWithAuth;
          };

          notifier.smtp = let
            fileRef = file: "{{- fileContent \"${file}\" }}";
          in {
            address = cfga.smtp.endpoint;
            inherit (cfga.smtp) username;
            password = fileRef config.sops.secrets."authelia/smtp/password".path;

            sender = "Authelia <auth@${cfg.hostname}>";
          };

          identity_providers.oidc = {
            clients =
              lib.mapAttrsToList (name: client: {
                client_id = name;
                client_secret = client.secretHash;
                redirect_uris = client.redirects;
                authorization_policy = "default";

                # Remember the user's consent to share data with apps
                # GDPR isn't really impacted since everything is internal,
                # it's just telling users what the individual app will have access to.
                pre_configured_consent_duration = "1 week";
              })
              cfga.oidcClients;

            # Require 2FA by default
            authorization_policies.default = {
              default_policy = "deny";

              rules = [
                {
                  subject = "group:human";
                  policy = "two_factor";
                }
              ];
            };

            cors = {
              # Only allow origins that are used by a client as a redirect URI
              # Protects against CSRF attacks
              allowed_origins_from_client_redirect_uris = true;
            };
          };

          # Display my domain name in apps
          totp.issuer = cfg.hostname;

          # Require email verification for sensitive actions such as changing passwords
          # or adding a TOTP device
          identity_validation = {
            elevated_session = {
              # Codes last 5 minutes from generation
              code_lifespan = "5 minutes";
              # Elevated sessions last 10 minutes before needing to renew
              elevation_lifespan = "10 minutes";
            };

            reset_password = {
              # Keep codes valid for 5 minutes
              jwt_lifespan = "5 minutes";
            };
          };

          # Require a secure password based on the zxcvbn library
          # rather than simple rules
          password_policy.zxcvbn = {
            enabled = true;
            # "safely unguessable"
            min_score = 3;
          };
        };

        secrets = {
          jwtSecretFile = config.sops.secrets."authelia/jwt-secret".path;
          storageEncryptionKeyFile = config.sops.secrets."authelia/storage-key".path;

          oidcHmacSecretFile = config.sops.secrets."authelia/oidc-hmac-secret".path;
          oidcIssuerPrivateKeyFile = config.sops.secrets."authelia/jwk-rsa-secret".path;
        };
      };
    };
}
