# Backup directories using Restic
{
  config,
  lib,
  ...
}: {
  options.custom.backup = {
    enable = lib.mkEnableOption "backups";

    repositories = lib.mkOption {
      description = ''
        Backups to manage with Restic

        The backup is encrypted using the password found in the host's secrets file.

        Backups run automatically at midnight, every night.
      '';
      default = {};

      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          source = lib.mkOption {
            description = ''
              The absolute path to the directory to backup.
            '';

            type = lib.types.str;
            example = "/home/bob/Documents";
          };

          # TODO: Allow multiple destinations (i.e., local and remote)
          destination = lib.mkOption {
            description = ''
              The absolute path to the directory to store the backup.
            '';

            type = lib.types.str;
            example = "/mnt/backup";
          };

          owner = lib.mkOption {
            description = ''
              The user that owns the source files and backups.
            '';
          };

          keep = let
            mkKeepOption = name: default: lib.mkOption {
              description = ''
                The number of ${name} backups to keep.
              '';
              type = lib.types.int;
              default = default;
            };
          in {
            daily = mkKeepOption "daily" 7;
            weekly = mkKeepOption "weekly" 4;
            monthly = mkKeepOption "monthly" 12;
          };

          password = lib.mkOption {
            description = ''
              The path to the password in the host's secrets file.
            '';
            example = "backup/password";
          };
        };
      });
    };
  };

  config = let
    cfg = config.custom.backup;

    mkPasswordPath = name: "backup/${name}";
  in lib.mkIf cfg.enable {
    # Make our passwords available in files
    sops.secrets = lib.attrsets.mapAttrs' (name: value: {
      name = mkPasswordPath name;
      value = {
        key = value.password;
        owner = value.owner;
      };
    }) cfg.repositories;

    # Create a backup for each source
    services.restic.backups = builtins.mapAttrs (name: value: {
      user = value.owner;
      repository = value.destination;
      paths = [ value.source ];

      pruneOpts = [
        "--keep-daily" (toString value.keep.daily)
        "--keep-weekly" (toString value.keep.weekly)
        "--keep-monthly" (toString value.keep.monthly)
      ];

      # This is the default, but it's good to be explicit
      timerConfig = {
        # Run at midnight, every night
        OnCalendar = "daily";
        # If the system is offline at midnight, run soon after the next boot
        Persistent = true;
      };

      passwordFile = config.sops.secrets.${mkPasswordPath name}.path;
    }) cfg.repositories;
  };
}
