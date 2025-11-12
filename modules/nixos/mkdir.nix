{
  config,
  lib,
  ...
}: {
  options.custom.mkdir = let
    inherit (lib) mkOption types;

    mkdirType = types.submodule {
      options = {
        user = mkOption {
          type = types.str;
          example = "robert";
          description = "User who owns the directory";
        };
        group = mkOption {
          type = types.str;
          example = "smiths";
          description = "Group who owns the directory";
        };
        permissions = mkOption {
          type = types.str;
          default = "700";
          description = "Permissions to assign to the directory";
        };
      };
    };
  in
    mkOption {
      type = types.attrsOf mkdirType;
      default = {};
      description = "Directories created automatically if they do not exist";
    };

  config = let
    cfg = config.custom.mkdir;
  in {
    systemd.tmpfiles.rules = lib.flatten (lib.mapAttrsToList (dir: opts: [
        # Create directory if it does not exist, owned by user and group, with permissions
        # Do not clean based on age
        "d '${dir}' ${opts.permissions} ${opts.user} ${opts.group} - -"
        # chmod/chown directory to match requested permissions and ownership
        "z '${dir}' ${opts.permissions} ${opts.user} ${opts.group} - -"
      ])
      cfg);
  };
}
