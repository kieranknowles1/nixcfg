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

    socket = "/run/copyparty/party.sock";
  in
    lib.mkIf cfgc.enable {
      systemd.services.copyparty.postStart = ''
        # preStart chmods to 700. We need 755 to have a safe
        # place to store the socket that nginx can access.
        chmod 755 /run/copyparty
      '';

      custom.server = {
        copyparty.dataDir = "${cfg.data.baseDirectory}/copyparty";
        subdomains.${cfgc.subdomain} = {
          proxySocket = socket;
        };

        # No widget here :(
        homepage.services = lib.singleton {
          group = "Media";
          name = "Copyparty";
          description = "File management";
          icon = "copyparty.svg";
          href = "https://${cfgc.subdomain}.${cfg.hostname}";
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

          # Display human-readable sizes
          # Mode 2c: 3 significant figures with colour coded orders of magnitude
          ui-filesz = "2c";

          # Index files search
          e2d = true;
          # Index metadata
          e2t = true;

          # Include upload timestamp
          mte = "+.up_at";
        };

        accounts =
          builtins.mapAttrs (name: _value: {
            passwordFile = config.sops.secrets."copyparty/password/${name}".path;
          })
          cfgc.users;

        volumes = let
          mkVolume = flags: path: defaultPerms: {
            inherit path flags;
            access = {
              # Give all users all permissions, including admin access
              # TODO: Configure this per-user
              ${defaultPerms} = "@acct";
            };
          };

          # TODO: Change group to a shared "immich-copyparty" group
          mkImmichVolume = let
            fields = ["ISO" "ShutterSpeed" "Aperture" "DateTimeOriginal"];
            jq = lib.getExe pkgs.jq;
            exiftool = lib.getExe pkgs.exiftool;
            extractScript = pkgs.writeShellScript "extract-metadata" ''
              ${exiftool} -json ${builtins.concatStringsSep " " (map (f: "-${f}") fields)} "$1" | ${jq} '.[0]'
            '';
          in
            mkVolume {
              # Make sure Immich can read uploads and write metadata in new files
              chmod_d = "777"; # RWX-RWX-RX-
              # Copyparty needs write access to delete partial uploads. Users
              # cannot delete as they lack the "d" permission.
              chmod_f = "644"; # RW-R-R

              # Extract EXIF metadata from images
              mte = "${builtins.concatStringsSep "," fields}";
              # Documentation on this is terrible, but I've been able to reverse engineer it.
              # `mtp` takes the form `tags,comma,separated=options,comma,separated,command`
              # `command` should output a JSON object with a key for each `tag` on stdout
              # Options prefixed with `e` filter operations by file extension, case insensitive
              # All tags must be enabled using the `mte` flag
              # Adding a script is not retroactive to existing uploads
              mtp = "${builtins.concatStringsSep "," fields}=ejpg,ejpeg,eraw,${extractScript}";
            };
        in {
          # All permissions
          "/" = mkVolume {} cfgc.dataDir "A";
          # Read, write, but not modify or delete
          "/oldies" = mkImmichVolume "${cfg.data.baseDirectory}/immich-oldies" "rw";
          "/camera" = mkImmichVolume "${cfg.data.baseDirectory}/immich-camera" "rw";
        };
      };

      users.users = {
        # Nginx group membership is required to assign the socket's group
        copyparty.extraGroups = ["nginx"];
      };
    };
}
