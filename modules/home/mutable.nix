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
        run ${lib.getExe cfg.package} activate ${configFile} ${config.home.homeDirectory}
      '';
  };
}
