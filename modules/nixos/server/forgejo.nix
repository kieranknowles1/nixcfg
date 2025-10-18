{
  config,
  lib,
  ...
}: {
  options.custom.server.forgejo = let
    inherit (lib) mkOption mkEnableOption types;
  in {
    enable = mkEnableOption ''
      Forgejo Git server.

      NOTE: You may have to manually create the $${dataDir}/custom/conf directory.

      NOTE: User creation is disabled. To add one, run the following command
      to create an admin who can create other users:
      ```sh
      nix build nixpkgs#forgejo
      sudo --user forgejo ./result/bin/gitea admin user create --admin --email $USER_EMAIL \
        --username $USER_NAME --config $dataDir/custom/conf/app.ini --random-password
      ```
    '';

    subdomain = mkOption {
      type = types.str;
      default = "git";
      description = "The subdomain for Forgejo.";
    };

    dataDir = mkOption {
      type = types.path;
      defaultText = "$${config.custom.server.data.baseDirectory}/forgejo";
      description = "The directory where Forgejo will store its data.";
    };
  };

  config = let
    cfg = config.custom.server;
    cfgf = cfg.forgejo;
  in
    lib.mkIf cfgf.enable {
      custom.server = {
        forgejo.dataDir = "${cfg.data.baseDirectory}/forgejo";
        subdomains.${cfgf.subdomain} = {
          # Bit confusing, HTTP_ADDR refers to a socket path when using unix sockets
          proxySocket = config.services.forgejo.settings.server.HTTP_ADDR;
        };

        homepage.services = lib.singleton {
          group = "Meta";
          name = "Forgejo";
          description = "Git hosting";
          icon = "forgejo.svg";
          href = "https://${cfgf.subdomain}.${cfg.hostname}";
          widget = {
            type = "gitea";
            config = {
              url = "http://${cfgf.subdomain}.${config.networking.hostName}.local";
              fields = ["repositories"];
            };
            secrets.key = {
              id = "FORGEJO_TOKEN";
              value = "forgejo/homepage-token";
            };
          };
        };
      };

      services.forgejo = {
        enable = true;
        stateDir = cfgf.dataDir;

        settings = {
          server = {
            ROOT_URL = "https://${cfgf.subdomain}.${cfg.hostname}";
            PROTOCOL = "http+unix";
          };

          service = {
            # This is not a public service
            DISABLE_REGISTRATION = true;
          };

          repository = {
            # Don't like github wikis, prefer using the same repo as the rest
            # of the project to keep everything in one place and easier to
            # cross-reference.
            DISABLED_REPO_UNITS = "repo.wiki";
          };

          database = {
            SQLITE_JOURNAL_MODE = "WAL";
          };

          ui = {
            # 1mb, in bytes. UI gets unwieldy well before this
            MAX_DISPLAY_FILE_SIZE = 1 * 1024 * 1024;
          };
        };

        # No need to complicate things
        database.type = "sqlite3";
      };
    };
}
