{
  lib,
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

  config = let
    cfg = config.custom.shortcuts;

    palette = lib.getExe cfg.palette.package;

    # Why didn't this work the first time? What did I change when doing git reset and rewriting the file?
    # Was it because it's 00:46 and I'm tired? Maybe. Maybe I just angered the Nix gods.
    toArgs = action: let
      command = lib.strings.escapeShellArg action.action;
      description = lib.strings.escapeShellArg action.description;
    in "${command} ${description}";

    sortedActions = lib.lists.sort (a: b: a.description < b.description) cfg.palette.actions;

    actionsArg = builtins.concatStringsSep " " (builtins.map toArgs sortedActions);
  in
    lib.mkIf (cfg.enable && (builtins.length cfg.palette.actions > 0)) {
      custom.shortcuts.hotkeys.keys = {
        "${cfg.palette.binding}" = {
          description = "Open the command palette";
          action = "${palette} ${actionsArg}";
        };
      };
    };
}
