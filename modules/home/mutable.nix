# Module for provisioning mutable files that can change after build time
{
  config,
  lib,
  pkgs,
  self,
  ...
}: {
  options.custom.mutable = let
    inherit (lib) mkOption mkPackageOption types;
  in {
    package = mkPackageOption pkgs.flake "activate-mutable" {};

    repository = mkOption {
      type = types.path;
      description = ''
        Path of the flake's source directory. Used to check validity of repoPath.
      '';
    };

    file = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          source = mkOption {
            type = types.path;
            description = "Path to the source file";
          };
          onConflict = mkOption {
            description = ''
              What to do if the file was modified outside of Nix.

              - `replace`: Silently replace the file with Nix's version.
                (note: this will run on boot, use sparingly)
              - `warn`: Log a warning and keep the file as is.
            '';

            type = types.enum ["replace" "warn"];
            default = "warn";
          };
          repoPath = mkOption {
            # Not a path, as we don't want this to be in the Nix store
            type = types.nullOr types.str;
            # In theory, this could be guessed automatically by checking the source's store path.
            # However, this would rely on the source being part of the same derivation, which assumes too
            # much about Nix's internals. Implicit behaviour in the most explicit operating system is almost
            # as bad as dynamic typing.
            # TODO: Throw a warning if repoPath is invalid. Use something like
            # builtins.pathExists ${self}/${repoPath}
            default = null;
            description = ''
              Path to the file relative to the flake's root.

              If unset, this file will still be provisioned but changes cannot be restored.
            '';
          };
        };
      });

      default = {};
      description = ''
        A set of mutable files that can change after build time.

        Key is the name of the file, value is a set with the source file path.

        Can only be regular files, not directories or symlinks.
      '';
    };
  };

  config = let
    cfg = config.custom.mutable;
  in {
    custom.mutable.repository = lib.mkDefault self;

    assertions = let
      checkRegularFile = name: value: {
        assertion = lib.filesystem.pathIsRegularFile value.source;
        message = "Mutable file ${name} must be a regular file, not a directory or symlink";
      };

      checkSameFile = name: value: let
        srcHash = builtins.hashFile "sha256" value.source;
        repoHash = builtins.hashFile "sha256" "${cfg.repository}/${value.repoPath}";
      in {
        # We need to use hashes rather than path equality, as the ./path syntax
        # creates its own derivation, which will have a different path to ${self}/path

        # This will also raise a build error if the file doesn't exist
        assertion = value.repoPath == null || (srcHash == repoHash);
        message = "repoPath for mutable file ${name} points to a different file";
      };

      checkAll = name: value: [
        (checkRegularFile name value)
        (checkSameFile name value)
      ];
    in
      lib.lists.flatten (lib.attrsets.mapAttrsToList checkAll cfg.file);

    # TODO: Use for other files described in the plan
    home.activation.activate-mutable = let
      configTransform = lib.attrsets.mapAttrsToList (name: value:
        {
          destination = name;
        }
        // value)
      cfg.file;
      configFile = pkgs.writeText "activate-mutable-config.json" (builtins.toJSON configTransform);
    in
      lib.hm.dag.entryAfter ["writeBoundary"] ''
        status=0
        run ${lib.getExe cfg.package} activate ${configFile} ${config.home.homeDirectory} || status=$?

        if [ $status -ne 0 ]; then
          echo "One or more mutable files failed to be provisioned"
        fi
      '';
  };
}
