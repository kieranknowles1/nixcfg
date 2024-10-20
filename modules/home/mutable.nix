# Module for provisioning mutable files that can change after build time
{
  config,
  lib,
  pkgs,
  ...
}: {
  options.custom.mutable = let
    inherit (lib) mkOption mkPackageOption types;
  in {
    package = mkPackageOption pkgs.flake "activate-mutable" {};

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
    assertions =
      lib.attrsets.mapAttrsToList (name: value: {
        assertion = lib.filesystem.pathIsRegularFile value.source;
        message = "Mutable file ${name} must be a regular file, not a directory or symlink";
      })
      cfg.file;

    # TODO: Use other files described in the plan
    home.activation.activate-mutable = let
      configFile = pkgs.writeText "activate-mutable-config.json" (builtins.toJSON cfg.file);
    in
      lib.hm.dag.entryAfter ["writeBoundary"] ''
        # TODO: A file failing to be provisioned shouldn't stop the whole activation, how do
        # we make it just a warning to the user?
        run ${lib.getExe cfg.package} activate ${configFile} ${config.home.homeDirectory}
      '';
  };
}
