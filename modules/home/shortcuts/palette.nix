{
  lib,
  pkgs,
  config,
  hostConfig,
  flake,
  ...
}: {
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
            type = lib.types.listOf lib.types.str;
            description = "The command to be executed when the action is selected. The first element is the command, the rest are arguments.";
          };
          description = lib.mkOption {
            type = lib.types.str;
            description = "A brief description of the action";
          };
        };
      });
    };
  };

  config = let
    cfg = config.custom.shortcuts;

    palette = lib.getExe cfg.palette.package;

    sortedActions = lib.lists.sort (a: b: a.description < b.description) cfg.palette.actions;
    actionsFile =
      pkgs.writeText "actions.json"
      (builtins.toJSON sortedActions);
  in
    lib.mkIf (cfg.enable && (builtins.length cfg.palette.actions > 0)) {
      custom.shortcuts.hotkeys.keys = {
        "${cfg.palette.binding}" = {
          description = "Open the command palette";
          action = "${palette} ${actionsFile}";
        };
      };
    };
}
