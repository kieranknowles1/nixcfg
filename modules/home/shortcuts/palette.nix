{
  lib,
  pkgs,
  config,
  ...
}: {
  options.custom.shortcuts.palette = {
    package = lib.mkPackageOption pkgs.flake "command-palette" {};

    # TODO: Use the new hotkeys format (key + modifier booleans, need to be refactored)
    # binding = lib.mkOption {
    #   description = ''
    #     The keybinding to open the command palette.
    #   '';

    #   type = lib.types.str;
    #   # Use alt + shift + p as it's similar to the standard "ctrl + shift + p", but doesn't conflict with other palletes
    #   default = "alt + shift + p";
    # };

    actions = lib.mkOption {
      description = ''
        A list of actions to be displayed in the command palette.
        Each action is a set containing a command to be executed and a description of the action.
      '';

      default = [];

      type = lib.types.listOf (lib.types.submodule {
        options = {
          action = lib.mkOption {
            type = lib.types.listOf (lib.types.either lib.types.str lib.types.path);
            description = "The command to be executed when the action is selected. The first element is the command, the rest are arguments.";
          };
          description = lib.mkOption {
            type = lib.types.str;
            description = "A brief description of the action";
          };
          useTerminal = lib.mkOption {
            type = lib.types.bool;
            description = "Whether the command should be run in a terminal";
            default = false;
          };
        };
      });
    };

    finalConfig = lib.mkOption {
      type = lib.types.path;
      description = "Built actions.json for the command palette";
      readOnly = true;
    };
  };

  config = let
    cfg = config.custom.shortcuts;

    palette = lib.getExe cfg.palette.package;

    sortedActions = lib.lists.sort (a: b: a.description < b.description) cfg.palette.actions;
    configFile = {
      # TODO: Proper option for this
      terminalArgs = ["alacritty" "--command"];
      commands = sortedActions;
    };
  in
    lib.mkIf (cfg.enable && (builtins.length cfg.palette.actions > 0)) {
      custom.shortcuts.palette = {
        finalConfig = pkgs.writeText "actions.json" (builtins.toJSON configFile);
      };

      custom.shortcuts.hotkeys.keys = [
        {
          key = "p";
          alt = true;
          shift = true;
          description = "Open the command palette";
          action = "${palette} --file ${cfg.palette.finalConfig}";
        }
      ];
    };
}
