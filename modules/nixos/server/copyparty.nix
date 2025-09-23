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
          # Listen on a socket, faster and more secure than HTTP
          i = "unix:770:nginx:${socket}";
          # Get the real IP of a client from here
          xff-hdr = "x-forwarded-for";
          xff-src = "127.0.0.0/8";
          # Use the second original IP. Nginx will add Cloudflare's proxy, while
          # we want to use the second which Cloudflare gave us.
          rproxy = -2;
          # Don't complain that we can't generate a certificate, it's pointless
          # with a reverse proxy
          no-crt = true;

          # Use password hashing with recommended parameters
          ah-alg = "argon2";
          ah-salt = "rupj20zyxka7M9FaeM+4jPjs";

          # Deduplicate files by converting to reflinks
          # Changes to one will not propagate to others
          dedup = true;
          # TODO: Once python 3.14 is on nixpkgs, can use reflinks
          hardlink-only = true;
          # reflink = true;

          # Allow sharing files with others
          shr = "/share";
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

          flags = {
            # Index files search
            e2d = true;
            # Index metadata
            e2t = true;
          };
        };
      };

      users.users = {
        # Nginx group membership is required to assign the socket's group
        copyparty.extraGroups = ["nginx"];
      };
    };
}
