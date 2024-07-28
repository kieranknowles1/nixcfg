{
  lib,
  config,
  hostConfig,
  flake,
  ...
}: let
  package = lib.meta.getExe config.custom.shortcuts.palette.package;

  toArgs = action: let
    command = lib.strings.escapeShellArg action.action;
    description = lib.strings.escapeShellArg action.description;
  in "${command} ${description}";

  actionArgs = builtins.map toArgs config.custom.shortcuts.palette.actions;
  actions = builtins.concatStringsSep " " actionArgs;
in {
  options.custom.shortcuts.palette = {
    package = lib.mkPackageOption flake.packages.${hostConfig.nixpkgs.hostPlatform.system} "command-palette" {};

    binding = lib.mkOption {
      description = ''
        The keybinding to open the command palette.
      '';

      type = lib.types.str;
      default = "alt + shift + p";
    };

    actions = lib.mkOption {
      description = ''
        A list of actions to be displayed in the command palette.
        Each action is a set containing a command to be executed and a description of the action.
      '';

      default = [];

      type = lib.types.listOf (lib.types.submodule {
        options = {
          action = lib.mkOption {
            type = lib.types.str;
            description = "The command to be executed when the action is selected";
          };
          description = lib.mkOption {
            type = lib.types.str;
            description = "A brief description of the action";
          };
        };
      });
    };
  };

  config = lib.mkIf config.custom.shortcuts.enable {
    custom.shortcuts.hotkeys.keys = {
      "${config.custom.shortcuts.palette.binding}" = {
        description = "Open the command palette";
        action = "${package} ${actions}";
      };
    };
  };
}
