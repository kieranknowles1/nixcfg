# Package a script to edit configuration files. Configurable via NixOS options.
{
  flake,
  lib,
  config,
  hostConfig,
  ...
}: let
  combinedConfig =
    config.custom.edit-config
    // {
      editor = config.custom.editor.default;
      repository = hostConfig.custom.repoPath;
    };
in {
  options.custom.edit-config = {
    enable = lib.mkEnableOption "edit-config script.";

    package = lib.mkPackageOption flake.packages.${hostConfig.nixpkgs.hostPlatform.system} "edit-config" {};

    programs = lib.mkOption {
      # TODO: Treeitter hightlighting for MarkDown, try to automate for all descriptions/doc comments
      description = ''
        Programs with configuration files to edit. The key will be used to
        select the configuration file via the command line.
      '';

      example = {
        edit-config.programs.test = {
          system-path = "~/.config/my-app";
          repo-path = "modules/home/my-app/config";
        };
      };

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
          ignore-paths = lib.mkOption {
            description = ''
              Paths to ignore when searching for configuration files.
              If a directory is listed, all files within it will be ignored.

              All paths are relative to system-path.
            '';
            type = lib.types.listOf lib.types.str;
            default = [];
            example = [
              "node_modules"
              "match/base.yml"
            ];
          };
        };
      });
    };
  };

  config = lib.mkIf config.custom.edit-config.enable {
    # Put our script on the PATH.
    home.packages = [config.custom.edit-config.package];

    # Provisioning a file in .config is easier than including it in the edit-config derivation.
    home.file."${config.xdg.configHome}/edit-config.json".text = builtins.toJSON combinedConfig;
  };
}
