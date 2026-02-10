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

    photos = {
      extensions = mkOption {
        type = types.listOf types.str;
        default = [
          "jpg"
          "jpeg"
          # Canon raw. Other formats will probably work, but I only have the one camera.
          "cr2"
        ];
        description = ''
          File extensions to index as photos and extract `metaFields` from.
        '';
      };

      metaFields = mkOption {
        type = types.listOf types.str;
        default = [
          "Aperture"
          "DateTimeOriginal"
          "FileNumber"
          "FocalLength"
          "ISO"
          "ShutterSpeed"
        ];
        description = ''
          EXIF metadata fields to extract from photos and index, will be
          displayed in photo directory listings.
        '';
      };
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
          immichFlags = let
            jq = lib.getExe pkgs.jq;
            exiftool = lib.getExe pkgs.exiftool;
            formatFlags = builtins.concatStringsSep "," (map (ext: "e${ext}") cfgc.photos.extensions);
            metaFlags = builtins.concatStringsSep "," cfgc.photos.metaFields;
            extractScript = pkgs.writeShellScript "extract-metadata" ''
              ${exiftool} -json ${builtins.concatStringsSep " " (map (f: "-${f}") cfgc.photos.metaFields)} "$1" | ${jq} '.[0]'
            '';
          in {
            # Immich needs write access to create sidecar metadata files. It
            # does not and cannot write images owned by copyparty.
            chmod_d = "770"; # RWX-RWX
            # Copyparty needs write access to delete partial uploads. Users
            # cannot delete as they lack the "d" permission.
            chmod_f = "640"; # RW-R
            gid = config.custom.gids.immich-copyparty;

            # Extract EXIF metadata from images
            mte = metaFlags;
            # Documentation on this is terrible, but I've been able to reverse engineer it.
            # `mtp` takes the form `tags,comma,separated=options,comma,separated,command`
            # `command` should output a JSON object with a key for each `tag` on stdout
            # Options prefixed with `e` filter operations by file extension, case insensitive
            # All tags must be enabled using the `mte` flag
            # Adding a script is not retroactive to existing uploads
            mtp = "${metaFlags}=${formatFlags},${extractScript}";
          };

          # TODO: Be more granular with who can access what
          LOGGED_IN = "@acct";
          UNAUTHENTICATED = "*";
          permissions = {
            # All permissions, including admin
            ALL = "rwmda.";
            READ = "r";
            # Upload files, but not modify or delete
            WRITE = "w";
          };
        in {
          # Default volume, allow logged in users to read/write anything
          # and have admin access
          "/" = {
            path = cfgc.dataDir;
            access.${permissions.ALL} = LOGGED_IN;
          };

          # Publicly accessible files, allowing anyone to read without
          # authentication
          "/public" = {
            path = "${cfgc.dataDir}/public";
            access.${permissions.ALL} = LOGGED_IN;
            access.${permissions.READ} = UNAUTHENTICATED;
          };

          # Immich archives, these are upload-only stores for Immich to pull from
          # Old videos archived from VHS
          "/oldies" = {
            path = "${cfg.data.baseDirectory}/immich-oldies";
            access.${permissions.READ} = LOGGED_IN;
            access.${permissions.WRITE} = LOGGED_IN;
            flags = immichFlags;
          };
          # DSLR photos
          "/camera" = {
            path = "${cfg.data.baseDirectory}/immich-camera";
            access.${permissions.READ} = LOGGED_IN;
            access.${permissions.WRITE} = LOGGED_IN;
            flags = immichFlags;
          };
        };
      };

      users.users = {
        # Nginx group membership is required to assign the socket's group
        # `immich-copyparty` gives both services shared access to read-only external library volumes
        # TODO: Use a shared group for nginx-copyparty-socket
        copyparty.extraGroups = ["nginx" "immich-copyparty"];
        immich.extraGroups = ["immich-copyparty"];
      };

      users.groups.immich-copyparty = {
        gid = config.custom.gids.immich-copyparty;
      };
    };
}
