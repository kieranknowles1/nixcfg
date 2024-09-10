{
  lib,
  pkgs,
  config,
  ...
}: {
  options.custom.shortcuts.palette = {
    package = lib.mkPackageOption pkgs.flake "command-palette" {};

    binding = lib.mkOption {
      description = ''
        The keybinding to open the command palette.
      '';

      type = lib.types.str;
      # Use alt + shift + p as it's similar to the standard "ctrl + shift + p", but doesn't conflict with other palletes
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
    zenity = lib.getExe pkgs.zenity;

    sortedActions = lib.lists.sort (a: b: a.description < b.description) cfg.palette.actions;
    actionsFile =
      pkgs.writeText "actions.json"
      (builtins.toJSON sortedActions);
  in
    lib.mkIf (cfg.enable && (builtins.length cfg.palette.actions > 0)) {
      custom.shortcuts.hotkeys.keys = {
        "${cfg.palette.binding}" = {
          description = "Open the command palette";
          action = "${palette} --zenity ${zenity} --file ${actionsFile}";
        };
      };
    };
}
