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

        Backups run automatically at midnight, every night. They can be manually triggered
        with `systemctl start restic-backups<name>.service` and managed with
        `restic-<name> ...`.

        See [Restic's documentation](https://restic.readthedocs.io/en/latest/) for more information.
        You do not need to set environment variables, the wrapper scripts handle this for you.
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

          exclude = lib.mkOption {
            description = ''
              A list of patterns to exclude from the backup.

              See [Backing up - Excluding Files](https://restic.readthedocs.io/en/latest/040_backup.html#excluding-files) for more information.
            '';

            type = lib.types.listOf lib.types.str;
            default = [];
            example = [
              ".git"
              "node_modules"
              "already-in-git"
            ];
          };

          # TODO: Allow multiple destinations (i.e., local and remote)
          destination = lib.mkOption {
            description = ''
              The absolute path to the directory to store the backup.
            '';

            type = lib.types.str;
            example = "/mnt/backup";
          };
          destinationIsSecret = lib.mkOption {
            description = ''
              Whether the destination points to a secret, or is a plain connection string.
            '';

            type = lib.types.bool;
            default = false;
          };

          owner = lib.mkOption {
            description = ''
              The user that owns the source files and backups.
            '';
          };

          keep = let
            mkKeepOption = name: default:
              lib.mkOption {
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

    mkPasswordPath = name: "backup/${name}/password";
    mkDestinationPath = name: "backup/${name}/destination";

    mkBackupSecrets = name: let
      value = cfg.repositories.${name};
    in
      (lib.lists.singleton {
        name = mkPasswordPath name;
        value = {
          key = value.password;
          owner = value.owner;
        };
      })
      ++ (lib.optional value.destinationIsSecret {
        name = mkDestinationPath name;
        value = {
          key = value.destination;
          owner = value.owner;
        };
      });

    backups = builtins.attrNames cfg.repositories;
    secrets = lib.lists.concatMap (name: mkBackupSecrets name) backups;
  in
    lib.mkIf cfg.enable {
      # Make our passwords available in files

      # Make any secrets available in files to the owner of the backup
      sops.secrets = builtins.listToAttrs secrets;

      # Create a backup for each source
      services.restic.backups =
        builtins.mapAttrs (name: value: {
          user = value.owner;
          paths = [value.source];
          exclude = value.exclude;

          pruneOpts = [
            "--keep-daily ${toString value.keep.daily}"
            "--keep-weekly ${toString value.keep.weekly}"
            "--keep-monthly ${toString value.keep.monthly}"
          ];

          # This is the default, but it's good to be explicit
          timerConfig = {
            # Run at midnight, every night
            OnCalendar = "daily";
            # If the system is offline at midnight, run soon after the next boot
            Persistent = true;
          };

          # It's easier to make the repository always stored in a file, rather than maybe a file, maybe a plain string
          repositoryFile =
            if value.destinationIsSecret
            then config.sops.secrets.${mkDestinationPath name}.path
            else builtins.toFile "${name}-destination-path" value.destination;
          passwordFile = config.sops.secrets.${mkPasswordPath name}.path;
        })
        cfg.repositories;
    };
}
