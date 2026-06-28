{
  config,
  lib,
  ...
}: {
  options.custom.server.papra = let
    inherit (lib) mkOption mkEnableOption types;
  in {
    enable = mkEnableOption "Papra";
    subdomain = mkOption {
      type = types.str;
      default = "papers";
      description = "The subdomain for Papra";
    };
    dataDir = mkOption {
      type = types.path;
      defaultText = "$${config.custom.server.data.baseDirectory}/papra";
      description = "The directory where Papra will store its documents";
    };
    dbDir = mkOption {
      type = types.path;
      defaultText = "$${config.custom.server.data.fastDirectory}/papra";
      description = "The directory where Papra will store its database";
    };
  };

  config = let
    cfg = config.custom.server;
    cfgp = cfg.papra;

    url = "https://${cfgp.subdomain}.${cfg.hostname}";
  in
    lib.mkIf cfgp.enable {
      custom.server = {
        papra.dataDir = "${cfg.data.baseDirectory}/papra";
        papra.dbDir = "${cfg.data.fastDirectory}/papra";
        subdomains.${cfgp.subdomain} = {
          proxyPort = cfg.ports.tcp.papra;
        };

        postgresql.enable = true;

        homepage.services = lib.singleton {
          group = "Documents";
          name = "Papra";
          description = "Document management system";
          icon = "papra.svg";
          href = url;
          # TODO: This isn't working currently
          # widget = {
          #   type = "paperlessngx";
          #   config.url = "http://${cfgp.subdomain}.${config.networking.hostName}.local";
          #   secrets.token = {
          #     id = "PAPERELESS_TOKEN";
          #     value = "paperless/token";
          #   };
          # };
        };
      };

      custom.mkdir = let
        ownership = {
          inherit (config.services.papra) user group;
        };
      in {
        "${cfgp.dataDir}" = ownership;
        "${cfgp.dbDir}" = ownership;
      };

      services.papra = {
        enable = true;

        environment = {
          # The base URL of the application. Will override the client baseUrl and
          # server baseUrl when set. Use this one over the client and server baseUrl
          # when the server is serving the client assets (like in docker).
          APP_BASE_URL = url;

          # A comma separated list of origins that are trusted to make requests to the
          # server. The client baseUrl (CLIENT_BASE_URL) is automatically added by
          # default, no need to add it to the list.
          # TRUSTED_ORIGINS=

          # A comma separated list of app schemes that are trusted for authentication.
          # For example: "papra://,exp://". Note, setting this value will override the
          # default schemes, so make sure to include them if needed.
          # TRUSTED_APP_SCHEMES=papra://,exp://

          # The port to listen on when using node server.
          PORT = cfg.ports.tcp.papra;

          # The hostname to bind to when using node server.
          # SERVER_HOSTNAME=0.0.0.0

          # The maximum time in milliseconds for a route to complete before timing out.
          # SERVER_API_ROUTES_TIMEOUT_MS=20000

          # The CORS origin for the api server.
          # SERVER_CORS_ORIGINS=http://localhost:3000

          # Whether to serve the public directory (default as true when using docker).
          # SERVER_SERVE_PUBLIC_DIR=false

          # The URL of the database
          DATABASE_URL = "file:${cfgp.dbDir}/papra.sqlite";

          # The auth token for the database.
          # DATABASE_AUTH_TOKEN=

          # The retention period in days for deleted documents.
          # DOCUMENTS_DELETED_DOCUMENTS_RETENTION_DAYS=30

          # The languages codes to use for OCR, multiple languages can be specified by
          # separating them with a comma. See
          # https://tesseract-ocr.github.io/tessdoc/Data-Files#data-files-for-version-400-november-29-2016.
          # DOCUMENTS_OCR_LANGUAGES=eng

          # Whether to enable content extraction (OCR and text extraction) for uploaded
          # documents.
          # DOCUMENTS_CONTENT_EXTRACTION_ENABLED=true

          # The maximum size in bytes for an uploaded file. Set to 0 to disable the
          # limit and allow uploading documents of any size.
          # DOCUMENT_STORAGE_MAX_UPLOAD_SIZE=26214400

          # The root directory to store documents in
          DOCUMENT_STORAGE_DRIVER = "filesystem";
          DOCUMENT_STORAGE_FILESYSTEM_ROOT = cfgp.dataDir;

          # Whether to use the legacy storage key definition system, which generates
          # storage keys in the format: {{organization.id}}/originals/{{document.id}}.
          # When set to true, no storage key pattern will be used, nor will the
          # incremental suffix or random suffix fallback mechanisms be enabled, as the
          # storage key will be generated using the legacy system.
          # DOCUMENT_STORAGE_USE_LEGACY_STORAGE_KEY_DEFINITION_SYSTEM=true

          # How many incremental suffixes to try when a storage key is already taken
          # (e.g. file_1.txt, file_2.txt, ...). Set to 0 to skip incremental suffixes
          # entirely.
          # DOCUMENT_STORAGE_PATTERN_MAX_INCREMENTAL_SUFFIX_ATTEMPTS=9

          # Whether to enable a fallback mechanism that adds a random alphanumeric
          # 8-character suffix to the storage key if all incremental suffix attempts
          # are exhausted.
          # DOCUMENT_STORAGE_PATTERN_ENABLE_RANDOM_SUFFIX_FALLBACK=true

          # The pattern to use for generating storage keys. This can include
          # expressions enclosed in double curly braces (e.g. {{document.name}}) that
          # will be evaluated at runtime.
          # DOCUMENT_STORAGE_KEY_PATTERN={{organization.id}}/{{document.name}}

          # The document search provider to use, values can be one of: `database-fts5`.
          # DOCUMENT_SEARCH_DRIVER=database-fts5

          # The secret for the auth, it should be at least 32 characters long, you can
          # generate a secure one using `openssl rand -hex 48`.
          # AUTH_SECRET=papra-default-auth-secret-change-me

          # Whether registration is enabled.
          # AUTH_IS_REGISTRATION_ENABLED=true

          # Whether password reset is enabled.
          # AUTH_IS_PASSWORD_RESET_ENABLED=true

          # Whether email verification is required.
          # AUTH_IS_EMAIL_VERIFICATION_REQUIRED=false

          # Automatically assign the admin role to the first user who registers. This
          # is useful for initial setup of self-hosted instances where you need an
          # admin account to manage the platform.
          # AUTH_FIRST_USER_AS_ADMIN=true

          # The header, or comma separated list of headers, to use to get the real IP
          # address of the user, use for rate limiting. Make sur to use a non-spoofable
          # header, one set by your proxy.
          # - If behind a standard proxy, you might want
          # to set this to "x-forwarded-for".
          # - If behind Cloudflare, you might want to
          # set this to "cf-connecting-ip".
          # AUTH_IP_ADDRESS_HEADERS=x-forwarded-for

          # A comma separated list of email domains that are forbidden for registration
          # (e.g. "foo.com,bar.com"), if set, it will override the default forbidden
          # domains.
          # AUTH_FORBIDDEN_EMAIL_DOMAINS=papra.app,papra.email,owlrelay.email,callback.email,clb.email

          # Whether email/password authentication is enabled.
          # AUTH_PROVIDERS_EMAIL_IS_ENABLED=true

          # Whether Github OAuth is enabled.
          # AUTH_PROVIDERS_GITHUB_IS_ENABLED=false

          # The client id for Github OAuth.
          # AUTH_PROVIDERS_GITHUB_CLIENT_ID=set-me

          # The client secret for Github OAuth.
          # AUTH_PROVIDERS_GITHUB_CLIENT_SECRET=set-me

          # Whether Google OAuth is enabled.
          # AUTH_PROVIDERS_GOOGLE_IS_ENABLED=false

          # The client id for Google OAuth.
          # AUTH_PROVIDERS_GOOGLE_CLIENT_ID=set-me

          # The client secret for Google OAuth.
          # AUTH_PROVIDERS_GOOGLE_CLIENT_SECRET=set-me

          # The list of custom OAuth providers, as a JSON string, see
          # https://www.better-auth.com/docs/plugins/generic-oauth#configuration for
          # more details.
          # AUTH_PROVIDERS_CUSTOMS=

          # Whether ingestion folders are enabled.
          # INGESTION_FOLDER_IS_ENABLED=false

          # The root directory in which ingestion folders for each organization are
          # stored.
          # INGESTION_FOLDER_ROOT_PATH=./ingestion

          # Whether to use polling for the ingestion folder watcher.
          # INGESTION_FOLDER_WATCHER_USE_POLLING=false

          # When polling is used, this is the interval at which the watcher checks for
          # changes in the ingestion folder (in milliseconds).
          # INGESTION_FOLDER_WATCHER_POLLING_INTERVAL_MS=2000

          # The amount of time in milliseconds for a file size to remain constant
          # before being consumed. This helps to avoid processing files that are still
          # being written to (e.g., scanners, cameras, network shares, etc.).
          # INGESTION_FOLDER_WATCHER_FILE_STABILITY_THRESHOLD_MS=2000

          # The interval in milliseconds at which the file size is polled while waiting
          # for write to finish.
          # INGESTION_FOLDER_WATCHER_FILE_STABILITY_POLL_INTERVAL_MS=100

          # The number of files that can be processed concurrently by the server.
          # Increasing this can improve processing speed, but it will also increase CPU
          # and memory usage.
          # INGESTION_FOLDER_PROCESSING_CONCURRENCY=1

          # The folder to move the file when the ingestion fails, the path is relative
          # to the organization ingestion folder (<ingestion root>/<organization id>).
          # INGESTION_FOLDER_ERROR_FOLDER_PATH=./ingestion-error

          # The action done on the file after it has been ingested.
          # INGESTION_FOLDER_POST_PROCESSING_STRATEGY=delete

          # The folder to move the file when the post-processing strategy is "move",
          # the path is relative to the organization ingestion folder (<ingestion
          # root>/<organization id>).
          # INGESTION_FOLDER_POST_PROCESSING_MOVE_FOLDER_PATH=./ingestion-done

          # Comma separated list of patterns to ignore when watching the ingestion
          # folder. Note that if you update this variable, it'll override the default
          # patterns, not merge them. Regarding the format and syntax, please refer to
          # the [picomatch
          # documentation](https://github.com/micromatch/picomatch/blob/bf6a33bd3db990edfbfd20b3b160eed926cd07dd/README.md#globbing-features).
          # INGESTION_FOLDER_IGNORED_PATTERNS=**/.DS_Store,**/.env,**/desktop.ini,**/Thumbs.db,**/.git/**,**/.idea/**,**/.vscode/**,**/node_modules/**,**/@eaDir/**,**/*@SynoResource,**/*@SynoEAStream

          # The cron schedule for the task to hard delete expired "soft deleted"
          # documents.
          # DOCUMENTS_HARD_DELETE_EXPIRED_DOCUMENTS_CRON=0 0 * * *

          # Whether the task to hard delete expired "soft deleted" documents should run
          # on startup.
          # DOCUMENTS_HARD_DELETE_EXPIRED_DOCUMENTS_RUN_ON_STARTUP=true

          # The cron schedule for the task to expire invitations.
          # ORGANIZATIONS_EXPIRE_INVITATIONS_CRON=0 0 * * *

          # Whether the task to expire invitations should run on startup.
          # ORGANIZATIONS_EXPIRE_INVITATIONS_RUN_ON_STARTUP=true

          # The cron schedule for the task to purge expired soft-deleted organizations.
          # ORGANIZATIONS_PURGE_EXPIRED_ORGANIZATIONS_CRON=0 1 * * *

          # Whether the task to purge expired soft-deleted organizations should run on
          # startup.
          # ORGANIZATIONS_PURGE_EXPIRED_ORGANIZATIONS_RUN_ON_STARTUP=true

          # The cron schedule for the task to purge expired key-value store entries
          # (only runs when the configured kv-store driver requires it, e.g. libsql).
          # KV_STORE_PURGE_EXPIRED_ENTRIES_CRON=0 2 * * *

          # Whether the task to purge expired key-value store entries should run on
          # startup.
          # KV_STORE_PURGE_EXPIRED_ENTRIES_RUN_ON_STARTUP=true

          # Whether intake emails are enabled.
          # INTAKE_EMAILS_IS_ENABLED=false

          # The secret to use when verifying webhooks, should be a random string
          # between 16 and 128 characters.
          # INTAKE_EMAILS_WEBHOOK_SECRET=please-change-me

          # The driver to use when generating email addresses for intake emails, value
          # can be one of: `owlrelay`, `catch-all`.
          # INTAKE_EMAILS_DRIVER=catch-all

          # The API key used to interact with OwlRelay for the intake emails.
          # OWLRELAY_API_KEY=change-me

          # The webhook URL to use when generating email addresses for intake emails
          # with OwlRelay, if not provided, the webhook will be inferred from the
          # server URL.
          # OWLRELAY_WEBHOOK_URL=

          # The domain to use when generating email addresses for intake emails with
          # OwlRelay, if not provided, the OwlRelay will use their default domain.
          # OWLRELAY_DOMAIN=

          # The domain to use when generating email addresses for intake emails when
          # using the `catch-all` driver.
          # INTAKE_EMAILS_CATCH_ALL_DOMAIN=papra.local

          # The driver to use when generating email addresses for intake emails, value
          # can be one of: `random`, `pattern`.
          # INTAKE_EMAILS_USERNAME_DRIVER=random

          # The pattern to use when generating email addresses usernames (before the @)
          # for intake emails. Available placeholders are: {{user.name}}, {{user.id}},
          # {{user.email.username}}, {{organization.id}}, {{organization.name}},
          # {{random.digits}}. Note: the resulting username will be slugified to remove
          # special characters and spaces.
          # INTAKE_EMAILS_USERNAME_DRIVER_PATTERN={{user.name}}-{{random.digits}}

          # The email address to send emails from.
          # EMAILS_FROM_ADDRESS=Papra <auth@mail.papra.app>

          # The driver to use when sending emails, value can be one of: `resend`,
          # `logger`, `smtp`. Using `logger` will not send anything but log them
          # instead.
          # EMAILS_DRIVER=logger

          # The API key for the Resend email service.
          # RESEND_API_KEY=

          # When using the logger email driver, the level to log emails at.
          # LOGGER_EMAIL_DRIVER_LOG_LEVEL=info

          # The host of the SMTP server.
          # SMTP_HOST=

          # The port of the SMTP server.
          # SMTP_PORT=587

          # The user of the SMTP server.
          # SMTP_USER=

          # The password of the SMTP server.
          # SMTP_PASSWORD=

          # Whether to use a secure connection to the SMTP server.
          # SMTP_SECURE=false

          # The raw configuration for the nodemailer SMTP client in JSON format for
          # advanced use cases. If set, this will override all other config options.
          # See https://nodemailer.com/smtp/ for more details.
          # SMTP_JSON_CONFIG=

          # The maximum number of organizations a standard user can have.
          # MAX_ORGANIZATION_COUNT_PER_USER=10

          # The number of days an invitation to an organization will be valid.
          # ORGANIZATION_INVITATION_EXPIRATION_DELAY_DAYS=7

          # The maximum number of invitations a user can send per day.
          # MAX_USER_ORGANIZATIONS_INVITATIONS_PER_DAY=30

          # The number of days before a soft-deleted organization is permanently
          # purged.
          # ORGANIZATIONS_DELETED_PURGE_DAYS_DELAY=30

          # The maximum number of tags an organization can have.
          # MAX_TAGS_PER_ORGANIZATION=200

          # The maximum number of custom property definitions an organization can have.
          # MAX_CUSTOM_PROPERTIES_PER_ORGANIZATION=100

          # The base URL used to generate share links, if not specified it'll use the
          # application `APP_BASE_URL` and the `CLIENT_BASE_URL` as fallback.
          # DOCUMENT_SHARE_LINKS_BASE_URL=

          # The lifetime, in minutes, of the access token issued after a successful
          # share-link password verification.
          # DOCUMENT_SHARE_LINKS_ACCESS_TOKEN_TTL_MINUTES=15

          # The rate limit applied to share link password verification attempts, to
          # prevent brute-force attacks, globally scoped. Expected formats matching
          # /^\d+\/\d*[smh]$/, like "10/h", "10/2h", "2/5m", etc. For example "10/h"
          # means 10 hits per hour, "10/2h" means 10 hits per 2 hours, "2/5m" means 2
          # hits per 5 minutes, etc. Units can be seconds (s), minutes (m) or hours
          # (h).
          # DOCUMENT_SHARE_LINKS_PASSWORD_VERIFICATION_RATE_LIMIT=30/1h

          # The rate limit applied to document access through share links, globally
          # scoped. Expected formats matching /^\d+\/\d*[smh]$/, like "10/h", "10/2h",
          # "2/5m", etc. For example "10/h" means 10 hits per hour, "10/2h" means 10
          # hits per 2 hours, "2/5m" means 2 hits per 5 minutes, etc. Units can be
          # seconds (s), minutes (m) or hours (h).
          # DOCUMENT_SHARE_LINKS_DOCUMENT_ACCESS_RATE_LIMIT=3600/1h

          # The rate limit applied to file access through share links, globally scoped.
          # Expected formats matching /^\d+\/\d*[smh]$/, like "10/h", "10/2h", "2/5m",
          # etc. For example "10/h" means 10 hits per hour, "10/2h" means 10 hits per 2
          # hours, "2/5m" means 2 hits per 5 minutes, etc. Units can be seconds (s),
          # minutes (m) or hours (h).
          # DOCUMENT_SHARE_LINKS_FILE_ACCESS_RATE_LIMIT=600/1h

          # Whether to enable PostHog.
          # POSTHOG_ENABLED=false

          # The API key for PostHog.
          # POSTHOG_API_KEY=set-me

          # The host for PostHog.
          # POSTHOG_HOST=https://eu.i.posthog.com

          # If false, the SSRF protection for webhook URLs will be fully disabled. This
          # is not recommended and should only be used if you understand the risks and
          # consequences of disabling this protection. Preferably, you should use the
          # webhookUrlAllowedHostnames (WEBHOOK_URL_ALLOWED_HOSTNAMES) setting to
          # specify allowed hostnames instead of disabling SSRF protection entirely.
          # WEBHOOK_SSRF_PROTECTION_ENABLED=true

          # A list of allowed hostnames for webhook URLs that would be considered safe
          # from SSRF attacks. If not set, all local, private and reserved IP addresses
          # will be blocked.
          # WEBHOOK_URL_ALLOWED_HOSTNAMES=

          # The driver to use for the key-value store, value can be one of:
          # `in-memory`, `libsql`.
          # KV_STORE_DRIVER=libsql

          # Whether the selfhst free plan entitlements is enabled for new claims.
          # SELFHST_ENTITLEMENTS_IS_ENABLED_FOR_NEW_CLAIMS=true
        };
      };
    };
}
