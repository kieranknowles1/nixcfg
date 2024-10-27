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

        All backups exist in pairs: one local, and one remote. The path to the local backup is
        plaintext, but the remote backup is considered sensitive and is stored in the secrets file.
        Passwords, of course, are always sensitive.
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

          destination.local = lib.mkOption {
            description = ''
              The absolute path to the local directory to store the backup.
            '';

            type = lib.types.str;
            example = "/mnt/backup";
          };

          destination.remote = lib.mkOption {
            description = ''
              The secret containing the connection string to the remote repository.
            '';

            type = lib.types.str;
            example = "backup/remote/repo";
          };

          owner = lib.mkOption {
            description = ''
              The user that owns the source files and backups.
            '';
          };

          keep = let
            mkKeepOption = name: default:
              lib.mkOption {
                inherit default;
                description = ''
                  The number of ${name} backups to keep.
                '';
                type = lib.types.int;
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
    mkRemotePath = name: "backup/${name}/remote";
    getSecret = path: config.sops.secrets.${path}.path;

    # Generate all the secrets needed for a backup
    mkBackupSecrets = name: let
      value = cfg.repositories.${name};
    in [
      {
        name = mkPasswordPath name;
        value = {
          inherit (value) owner;
          key = value.password;
        };
      }
      {
        name = mkRemotePath name;
        value = {
          inherit (value) owner;
          key = value.destination.remote;
        };
      }
    ];

    backups = builtins.attrNames cfg.repositories;
    secrets = lib.lists.concatMap mkBackupSecrets backups;

    # Generate a backup configuration
    mkBackup = name: pairName: config: repoOrRepoFile: {
      inherit name;
      value =
        {
          inherit (config) exclude;
          user = config.owner;
          paths = [config.source];

          pruneOpts = [
            "--keep-daily ${toString config.keep.daily}"
            "--keep-weekly ${toString config.keep.weekly}"
            "--keep-monthly ${toString config.keep.monthly}"
          ];

          # This is the default, but it's good to be explicit
          timerConfig = {
            # Run at midnight, every night
            OnCalendar = "daily";
            # If the system is offline at midnight, run soon after the next boot
            Persistent = true;
          };

          passwordFile = getSecret (mkPasswordPath pairName);
        }
        // repoOrRepoFile;
    };

    mkBackupPair = name: let
      thisRepo = cfg.repositories.${name};
    in [
      (mkBackup name name thisRepo {repository = thisRepo.destination.local;})
      (mkBackup "${name}-remote" name thisRepo {repositoryFile = getSecret (mkRemotePath name);})
    ];
  in
    lib.mkIf cfg.enable {
      # Make any secrets available in files to the owner of the backup
      sops.secrets = builtins.listToAttrs secrets;

      # Configure a pair of backups for each repository
      services.restic.backups = builtins.listToAttrs (
        builtins.concatMap mkBackupPair backups
      );
    };
}
