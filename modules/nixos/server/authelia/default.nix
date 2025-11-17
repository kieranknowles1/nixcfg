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
          # such as Actualbudget
          access_control = {
            default_policy = "deny";
            rules = [
              # Anything to do with my services -> 2FA
              {
                domain = "*.${cfg.hostname}";
                policy = "two_factor";
              }
            ];
          };

          # TODO: Finish configuring
          # ##
          # ## Access Control Configuration
          # ##
          # ## Access control is a list of rules defining the authorizations applied for one resource to users or group of users.
          # ##
          # ## If 'access_control' is not defined, ACL rules are disabled and the 'deny' rule is applied, i.e., access is denied
          # ## to everyone. Otherwise restrictions follow the rules defined.
          # ##
          # ## Note: One can use the wildcard * to match any subdomain.
          # ## It must stand at the beginning of the pattern. (example: *.example.com)
          # ##
          # ## Note: You must put patterns containing wildcards between simple quotes for the YAML to be syntactically correct.
          # ##
          # ## Definition: A 'rule' is an object with the following keys: 'domain', 'subject', 'policy' and 'resources'.
          # ##
          # ## - 'domain' defines which domain or set of domains the rule applies to.
          # ##
          # ## - 'subject' defines the subject to apply authorizations to. This parameter is optional and matching any user if not
          # ##    provided. If provided, the parameter represents either a user or a group. It should be of the form
          # ##    'user:<username>' or 'group:<groupname>'.
          # ##
          # ## - 'policy' is the policy to apply to resources. It must be either 'bypass', 'one_factor', 'two_factor' or 'deny'.
          # ##
          # ## - 'resources' is a list of regular expressions that matches a set of resources to apply the policy to. This parameter
          # ##   is optional and matches any resource if not provided.
          # ##
          # ## Note: the order of the rules is important. The first policy matching (domain, resource, subject) applies.
          # # access_control:
          #   ## Default policy can either be 'bypass', 'one_factor', 'two_factor' or 'deny'. It is the policy applied to any
          #   ## resource if there is no policy to be applied to the user.
          #   # default_policy: 'deny'

          #   # rules:
          #     ## Rules applied to everyone
          #     # - domain: 'public.example.com'
          #     #   policy: 'bypass'

          #     ## Domain Regex examples. Generally we recommend just using a standard domain.
          #     # - domain_regex: '^(?P<User>\w+)\.example\.com$'
          #     #   policy: 'one_factor'
          #     # - domain_regex: '^(?P<Group>\w+)\.example\.com$'
          #     #   policy: 'one_factor'
          #     # - domain_regex:
          #       #  - '^appgroup-.*\.example\.com$'
          #       #  - '^appgroup2-.*\.example\.com$'
          #     #   policy: 'one_factor'
          #     # - domain_regex: '^.*\.example\.com$'
          #     #   policy: 'two_factor'

          #     # - domain: 'secure.example.com'
          #     #   policy: 'one_factor'
          #     ## Network based rule, if not provided any network matches.
          #     #   networks:
          #         # - 'internal'
          #         # - 'VPN'
          #         # - '192.168.1.0/24'
          #         # - '10.0.0.1'

          #     # - domain:
          #         # - 'secure.example.com'
          #         # - 'private.example.com'
          #     #   policy: 'two_factor'

          #     # - domain: 'singlefactor.example.com'
          #     #   policy: 'one_factor'

          #     ## Rules applied to 'admins' group
          #     # - domain: 'mx2.mail.example.com'
          #     #   subject: 'group:admins'
          #     #   policy: 'deny'

          #     # - domain: '*.example.com'
          #     #   subject:
          #         # - 'group:admins'
          #         # - 'group:moderators'
          #     #   policy: 'two_factor'

          #     ## Rules applied to 'dev' group
          #     # - domain: 'dev.example.com'
          #     #   resources:
          #         # - '^/groups/dev/.*$'
          #     #   subject: 'group:dev'
          #     #   policy: 'two_factor'

          #     ## Rules applied to user 'john'
          #     # - domain: 'dev.example.com'
          #     #   resources:
          #         # - '^/users/john/.*$'
          #     #   subject: 'user:john'
          #     #   policy: 'two_factor'

          #     ## Rules applied to user 'harry'
          #     # - domain: 'dev.example.com'
          #     #   resources:
          #         # - '^/users/harry/.*$'
          #     #   subject: 'user:harry'
          #     #   policy: 'two_factor'

          #     ## Rules applied to user 'bob'
          #     # - domain: '*.mail.example.com'
          #     #   subject: 'user:bob'
          #     #   policy: 'two_factor'
          #     # - domain: 'dev.example.com'
          #     #   resources:
          #     #     - '^/users/bob/.*$'
          #     #   subject: 'user:bob'
          #     #   policy: 'two_factor'

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
##############################################################################
#                           Authelia Configuration                          ##
##############################################################################
# Sourced from https://github.com/authelia/authelia/blob/master/config.template.yml
##      The comments in this configuration file are helpful but users should consult the official documentation on the
##      website at https://www.authelia.com/ or https://www.authelia.com/configuration/prologue/introduction/
# ## Set the default 2FA method for new users and for when a user has a preferred method configured that has been
# ## disabled. This setting must be a method that is enabled.
# ## Options are totp, webauthn, mobile_push.
# # default_2fa_method: ''
# ##
# ## Server Configuration
# ##
# # server:
#   ## Disables writing the health check vars to /app/.healthcheck.env which makes healthcheck.sh return exit code 0.
#   ## This is disabled by default if either /app/.healthcheck.env or /app/healthcheck.sh do not exist.
#   # disable_healthcheck: false
#   ## Server Endpoints configuration.
#   ## This section is considered advanced and it SHOULD NOT be configured unless you've read the relevant documentation.
#   # endpoints:
#     ## Enables the pprof endpoint.
#     # enable_pprof: false
#     ## Enables the expvars endpoint.
#     # enable_expvars: false
#     ## Configure the authz endpoints.
#     # authz:
#       # forward-auth:
#         # implementation: 'ForwardAuth'
#         # authn_strategies: []
#       # ext-authz:
#         # implementation: 'ExtAuthz'
#         # authn_strategies: []
#       # auth-request:
#         # implementation: 'AuthRequest'
#         # authn_strategies: []
#       # legacy:
#         # implementation: 'Legacy'
#         # authn_strategies: []
# ##
# ## WebAuthn Configuration
# ##
# ## Parameters used for WebAuthn.
# # webauthn:
#   ## Disable WebAuthn.
#   # disable: false
#   ## Enables logins via a Passkey.
#   # enable_passkey_login: false
#   ## The display name the browser should show the user for when using WebAuthn to login/register.
#   # display_name: 'Authelia'
#   ## Conveyance preference controls if we collect the attestation statement including the AAGUID from the device.
#   ## Options are none, indirect, direct.
#   # attestation_conveyance_preference: 'indirect'
#   ## The interaction timeout for WebAuthn dialogues in the duration common syntax.
#   # timeout: '60 seconds'
#   ## Selection Criteria controls the preferences for registration.
#   # selection_criteria:
#     ## The attachment preference. Either 'cross-platform' for dedicated authenticators, or 'platform' for embedded
#     ## authenticators.
#     # attachment: 'cross-platform'
#     ## The discoverability preference. Options are 'discouraged', 'preferred', and 'required'.
#     # discoverability: 'discouraged'
#     ## User verification controls if the user must make a gesture or action to confirm they are present.
#     ## Options are required, preferred, discouraged.
#     # user_verification: 'preferred'
#   ## Metadata Service validation via MDS3.
#   # metadata:
#     ## Enable the metadata fetch behaviour.
#     # enabled: false
#     ## Configure the Cache Policy for the Metadata Service.
#     # cache_policy: 'strict'
#     ## Enable Validation of the Trust Anchor. This generally should be enabled if you're using the metadata. It
#     ## ensures the attestation certificate presented by the authenticator is valid against the MDS3 certificate that
#     ## issued the attestation certificate.
#     # validate_trust_anchor: true
#     ## Enable Validation of the Entry. This ensures that the MDS3 actually contains the metadata entry. If not enabled
#     ## attestation certificates which are not formally registered will be skipped. This may potentially exclude some
#     ## virtual authenticators.
#     # validate_entry: true
#     ## Enabling this allows attestation certificates with a zero AAGUID to pass validation. This is important if you do
#     ## use non-conformant authenticators like Apple ID.
#     # validate_entry_permit_zero_aaguid: false
#     ## Enable Validation of the Authenticator Status.
#     # validate_status: true
#     ## List of statuses which are considered permitted when validating an authenticator's metadata. Generally it is
#     ## recommended that this is not configured as any other status the authenticator's metadata has will result in an
#     ## error. This option is ineffectual if validate_status is false.
#     # validate_status_permitted: ~
#     ## List of statuses that should be prohibited when validating an authenticator's metadata. Generally it is
#     ## recommended that this is not configured as there are safe defaults. This option is ineffectual if validate_status
#     ## is false, or validate_status_permitted has values.
#     # validate_status_prohibited: ~

