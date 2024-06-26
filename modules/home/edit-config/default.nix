# Package a script to edit configuration files. Configurable via NixOS options.
{
  flake,
  lib,
  config,
  ...
}: let
  package = flake.lib.package.packagePythonScript "edit-config" ./edit-config.py "3.1.0";

  combinedConfig =
    config.custom.edit-config
    // {
      repository = "~/${config.custom.repoPath}";
    };
in {
  options.custom.edit-config = {
    # TODO: Remove this and just use config.custom.editor
    editor = lib.mkOption {
      description = ''
        The editor to use when editing configuration files. May be GUI or CLI, so long
        as it accepts a file path as an argument.
      '';

      type = lib.types.str;
      default = "code";
    };

    programs = lib.mkOption {
      description = ''
        Programs with configuration files to edit. The key will be used to
        select the configuration file via the command line.
      '';

      # attrsOf + submodule gives us a syntax similar to a JSON object
      # which is merged by Nix.
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          system-path = lib.mkOption {
            description = ''
              The path to the configuration file on disk.
              Tildes are expanded to the user's home directory.
            '';
            type = lib.types.str;
          };
          repo-path = lib.mkOption {
            description = ''
              The path to the configuration file relative to the repository root.
            '';
            # We can't use lib.types.path here because it will point to the
            # store, not the repository.
            type = lib.types.str;
          };
          ignore-dirs = lib.mkOption {
            description = ''
              Top-level directories to ignore when searching for files.
            '';
            type = lib.types.listOf lib.types.str;
            default = [];
            example = ["node_modules"];
          };
          nix-managed-paths = lib.mkOption {
            description = ''
              Paths that are managed by Nix and should be ignored.
            '';
            type = lib.types.listOf lib.types.str;
            default = [];
            example = ["match/base.yml"];
          };
        };
      });
    };
  };

  config = {
    # Put our script on the PATH.
    home.packages = [package];

    # Provisioning a file in .config is easier than including it in the edit-config derivation.
    home.file."${config.xdg.configHome}/edit-config.json".text = builtins.toJSON combinedConfig;
  };
}
