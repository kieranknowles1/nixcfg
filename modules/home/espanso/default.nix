{
  config,
  hostConfig,
  lib,
  ...
}: let
  userDetails = config.custom.userDetails;
in {
  options.custom = let
    inherit (lib) mkOption types;
  in {
    userDetails = {
      email = mkOption {
        description = "Email address";
        type = types.str;
        example = "bob@example.com";
      };
      firstName = mkOption {
        description = "First name";
        type = types.str;
        example = "Bob";
      };
      surName = mkOption {
        description = "Surname";
        type = types.str;
        example = "Smith";
      };
    };

    espanso = {
      # TODO: Add enable option

      packages = lib.mkOption {
        description = ''
          A list of Espanso packages to install.
        '';

        type = types.attrsOf (types.submodule {
          options = {
            url = mkOption {
              description = "URL to a tarball of the package";
              type = types.str;
              example = "https://github.com/espanso/espanso-package/archive/refs/heads/master.tar.gz";
            };
            hash = mkOption {
              description = "SHA256 hash of the package";
              type = types.str;
              default = ""; # Nix will use a placeholder and tell us the correct hash
              example = "sha256-...";
            };
            dir = mkOption {
              description = "If set, use a subdirectory of the package as the source";
              type = types.nullOr types.str;
              default = null;
              example = "package-dir";
            };
          };
        });
      };
    };
  };

  # Espanso doesn't make sense on a headless server
  config = lib.mkIf hostConfig.custom.features.desktop {
    # TODO: Move this to user config
    custom.espanso.packages = {
      misspell-en = {
        url = "https://github.com/timorunge/espanso-misspell-en/archive/refs/heads/master.tar.gz";
        hash = "sha256:1g3rd60jcqij5zhaicgcp73z31yfc3j4nbd29czapbmxjv3yi8yy";
        dir = "misspell-en/0.1.2";
      };
      misspell-en-uk = {
        url = "https://github.com/timorunge/espanso-misspell-en/archive/refs/heads/master.tar.gz";
        hash = "sha256:1g3rd60jcqij5zhaicgcp73z31yfc3j4nbd29czapbmxjv3yi8yy";
        dir = "misspell-en_UK/0.1.2";
      };
    };

    services.espanso = {
      enable = true;
      # Don't manage configs here, apart from the base match file
      # which we'll use for matches that use variables
      configs = {};
      matches.base = {
        matches = [
          {
            trigger = ":email:";
            replace = userDetails.email;
          }
          {
            trigger = ":name:";
            replace = "${userDetails.firstName} ${userDetails.surName}";
          }
          {
            triggers = [":firstname:" ":fname:"];
            replace = userDetails.firstName;
          }
          {
            triggers = [":surname:" ":sname:"];
            replace = userDetails.surName;
          }
        ];

        # Variables that we expose to all match files. Used when cleaner
        # than the Nix syntax or for app-specific match files
        global_vars = let
          # All variables in Espanso come from one of several sources.
          # We are only interested in constants here, so we use the echo
          # type to define them.
          # This is a helper as the syntax is a bit verbose
          mkGlobalVar = name: value: {
            inherit name;
            type = "echo";
            params.echo = value;
          };
        in [
          (mkGlobalVar "email" userDetails.email)
          (mkGlobalVar "firstname" userDetails.firstName)
          (mkGlobalVar "surname" userDetails.surName)
        ];
      };
    };

    xdg.configFile = let
      base = {
        espanso = {
          source = ./config;
          recursive = true;
        };
      };

      packages = lib.attrsets.mapAttrs' (name: package: {
        name = "espanso-package-${name}";
        value = {
          source = let
            file = builtins.fetchTarball { url = package.url; sha256 = package.hash; };
          in if package.dir != null then "${file}/${package.dir}" else file;

          target = "espanso/match/packages/${name}";
        };
      }) config.custom.espanso.packages;
    in base // packages;
  };
}
