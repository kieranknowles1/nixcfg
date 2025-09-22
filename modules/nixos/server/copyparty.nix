{
  config,
  lib,
  pkgs,
  ...
}: {
  options.custom.server.copyparty = let
    inherit (lib) mkOption mkEnableOption types;
    userType = types.submodule {
      options = {
        passwordSecret = mkOption {
          type = types.str;
          description = ''
            SOPS secret containing this user's password hash.
            Generated using `copyparty --ah-alg argon2 --ah-gen`.
          '';
        };
      };
    };
  in {
    enable = mkEnableOption "Copyparty";

    subdomain = mkOption {
      type = types.str;
      default = "files";
      description = "The subdomain for Copyparty";
    };

    dataDir = mkOption {
      type = types.path;
      defaultText = "$${config.custom.server.data.baseDirectory}/copyparty";
      description = "The directory where Copyparty will store the default volume";
    };

    users = mkOption {
      type = types.attrsOf userType;
      description = "Users who can access Copyparty";
    };
  };

  config = let
    cfg = config.custom.server;
    cfgc = cfg.copyparty;

    socket = "/dev/shm/party.sock";
  in
    lib.mkIf cfgc.enable {
      custom.server = {
        # TODO: Integrate with homepage
        copyparty.dataDir = "${cfg.data.baseDirectory}/copyparty";
        subdomains.${cfgc.subdomain} = {
          proxySocket = socket;
        };
      };

      environment.systemPackages = [pkgs.copyparty];

      sops.secrets =
        lib.attrsets.mapAttrs' (name: value: {
          name = "copyparty/password/${name}";
          value = {
            key = value.passwordSecret;
            owner = config.services.copyparty.user;
          };
        })
        cfgc.users;

      services.copyparty = {
        enable = true;
        settings = {
          # Listen address
          i = "unix:770:nginx:${socket}";
          # Get the real IP of a client from here
          xff-hdr = "x-forwarded-for";
          xff-src = "127.0.0.0/8";

          # Use password hashing with recommended parameters
          ah-alg = "argon2";
          ah-salt = "rupj20zyxka7M9FaeM+4jPjs";
        };

        accounts =
          builtins.mapAttrs (name: _value: {
            passwordFile = config.sops.secrets."copyparty/password/${name}".path;
          })
          cfgc.users;

        volumes."/" = {
          path = cfgc.dataDir;
          access = {
            # Give all users all permissions, including admin access
            # TODO: Configure this per-user
            A = "@acct";
          };
        };
      };

      users = {
        users.copyparty.extraGroups = ["nginx"];
      };
    };
}
