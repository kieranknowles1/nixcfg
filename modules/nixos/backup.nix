# Backup directories using Restic
{
  config,
  lib,
  pkgs,
  ...
}: {
  options.custom.backup = let
    inherit (lib) mkOption mkEnableOption types;

    mkKeepOption = name: default:
      mkOption {
        inherit default;
        description = ''
          The number of ${name} backups to keep.
        '';
        type = types.int;
      };
  in {
    enable = mkEnableOption "backups";

    repositories = mkOption {
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

      type = types.attrsOf (types.submodule {
        options = {
          source = mkOption {
            description = ''
              The absolute path to the directory to backup.
            '';

            type = types.str;
            example = "/home/bob/Documents";
          };

          exclude = mkOption {
            description = ''
              A list of patterns to exclude from the backup.

              See [Backing up - Excluding Files](https://restic.readthedocs.io/en/latest/040_backup.html#excluding-files) for more information.
            '';

            type = types.listOf types.str;
            default = [];
            example = [
              ".git"
              "node_modules"
              "already-in-git"
            ];
          };

          destination.local = mkOption {
            description = ''
              The absolute path to the local directory to store the backup.
            '';

            type = types.str;
            example = "/mnt/backup";
          };

          destination.remote = mkOption {
            description = ''
              The secret containing the connection string to the remote repository.
            '';

            type = types.str;
            example = "backup/remote/repo";
          };

          owner = mkOption {
            description = ''
              The user that owns the source files and backups.
            '';
            type = types.str;
            example = "bob";
          };

          keep = {
            daily = mkKeepOption "daily" 7;
            weekly = mkKeepOption "weekly" 4;
            monthly = mkKeepOption "monthly" 12;
          };

          password = mkOption {
            description = ''
              The path to the password in the host's secrets file.
            '';
            type = types.str;
            example = "backup/password";
          };

          btrfs = {
            useSnapshots = mkOption {
              description = ''
                Whether to use snapshots for backups. Allows for live backups,
                but requires files to be on a Btrfs filesystem.

                Additionally requires that the backup is run as root so that
                it has the ability to create snapshots.
              '';
              type = types.bool;
              default = false;
            };
            snapshotPath = mkOption {
              description = ''
                Location to store snapshots during backups. Must be on the same
                filesystem as the source files. File will only exist during the
                backup process.
              '';
              type = types.str;
              example = "/mnt/drive/backup-work-snapshot";
            };
          };
        };
      });
    };
  };

  config = let
    cfg = config.custom.backup;
    btrfs = "${pkgs.btrfs-progs}/bin/btrfs";

    optionalSecret = owner: name: key:
      lib.optional (key != null) {
        inherit name;
        value = {
          inherit owner key;
        };
      };

    mkPasswordPath = name: "backup/${name}/password";
    mkRemotePath = name: "backup/${name}/remote";
    getSecret = path: config.sops.secrets.${path}.path;

    # Generate all the secrets needed for a backup
    mkBackupSecrets = name: let
      repo = cfg.repositories.${name};
    in
      (optionalSecret repo.owner (mkPasswordPath name) repo.password)
      ++ (optionalSecret repo.owner (mkRemotePath name) repo.destination.remote);

    backups = builtins.attrNames cfg.repositories;
    secrets = lib.lists.concatMap mkBackupSecrets backups;

    # Generate a backup configuration

    mkBackupPair = name: let
      cfgr = cfg.repositories.${name};

      finalPath =
        if cfgr.btrfs.useSnapshots
        then cfgr.btrfs.snapshotPath
        else cfgr.source;

      common = tmpname: {
        inherit (cfgr) exclude;
        user = cfgr.owner;
        paths = [finalPath];

        backupPrepareCommand = lib.optionalString cfgr.btrfs.useSnapshots ''
          # Create a read-only snapshot of the source directory
          mkdir --parents "${cfgr.btrfs.snapshotPath}"
          ${btrfs} subvolume snapshot -r "${cfgr.source}" "${cfgr.btrfs.snapshotPath}/${tmpname}"
        '';
        backupCleanupCommand = lib.optionalString cfgr.btrfs.useSnapshots ''
          ${btrfs} subvolume delete "${cfgr.btrfs.snapshotPath}/${tmpname}"
        '';

        pruneOpts = [
          "--keep-daily ${toString cfgr.keep.daily}"
          "--keep-weekly ${toString cfgr.keep.weekly}"
          "--keep-monthly ${toString cfgr.keep.monthly}"
        ];

        # Report progress during backups. Not too often to avoid spamming the logs
        progressFps = 0.1;

        # Compress as much as possible. Bulk of my data is images which compress
        # poorly, but I want to minimise costs for cloud storage. Backups run at
        # midnight so I'm expecting plenty of CPU time to be free.
        extraBackupArgs = [
          "--compression=max"
        ];

        timerConfig = {
          # Run at midnight, every night
          OnCalendar = "daily";
          # If the system is offline at midnight, run soon after the next boot
          Persistent = true;
        };

        passwordFile = getSecret (mkPasswordPath name);
      };
    in [
      {
        inherit name;
        value = (common "local") // {repository = cfgr.destination.local;};
      }
      {
        name = "${name}-remote";
        value = (common "remote") // {repositoryFile = getSecret (mkRemotePath name);};
      }
    ];
  in
    lib.mkIf cfg.enable {
      assertions =
        lib.attrsets.mapAttrsToList (name: value: {
          assertion = value.btrfs.useSnapshots == false || value.owner == "root";
          message = "${name} must be run as root in order to work with btrfs snapshots";
        })
        cfg.repositories;

      # Make any secrets available in files to the owner of the backup
      sops.secrets = builtins.listToAttrs secrets;

      # Configure a pair of backups for each repository
      services.restic.backups = builtins.listToAttrs (
        builtins.concatMap mkBackupPair backups
      );
    };
}
