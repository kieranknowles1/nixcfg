{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.custom.shortcuts.palette =
    let
      inherit (lib)
        mkOption
        mkEnableOption
        mkPackageOption
        types
        ;
      mkBindingOption =
        name: type: default:
        mkOption {
          inherit type default;
          description = "${name} to open the command palette.";
        };
      mkModifierOption =
        name: default: mkBindingOption "Whether the ${name} key must be held" types.bool default;
    in
    {
      enable = mkEnableOption "command palette";

      package = mkPackageOption pkgs.flake "command-palette" { };

      binding = {
        key = mkBindingOption "The key" types.str "p";
        alt = mkModifierOption "alt" true;
        shift = mkModifierOption "shift" true;
        ctrl = mkModifierOption "ctrl" false;
      };

      actions = mkOption {
        description = ''
          A list of actions to be displayed in the command palette.
          Each action is a set containing a command to be executed and a description of the action.
        '';

        default = [ ];

        type = types.listOf (
          types.submodule {
            options = {
              action = mkOption {
                type = types.listOf (types.either types.str types.path);
                description = "The command to be executed when the action is selected. The first element is the command, the rest are arguments.";
              };
              description = mkOption {
                type = types.str;
                description = "A brief description of the action";
              };
              useTerminal = mkOption {
                type = types.bool;
                description = "Whether the command should be run in a terminal";
                default = false;
              };
            };
          }
        );
      };

      finalConfig = lib.mkOption {
        type = lib.types.path;
        description = "Built actions.json for the command palette";
        readOnly = true;
      };
    };

  config =
    let
      cfg = config.custom.shortcuts.palette;

      palette = lib.getExe cfg.package;

      sortedActions = lib.lists.sort (a: b: a.description < b.description) cfg.actions;
      configFile = {
        terminalScript = config.custom.terminal.runTermWait;
        commands = sortedActions;
      };
    in
    lib.mkIf (cfg.enable && (builtins.length cfg.actions > 0)) {
      assertions = lib.singleton {
        assertion = config.custom.shortcuts.hotkeys.enable;
        message = "Hotkeys are required for the command palette to be accessible";
      };

      custom.shortcuts.palette = {
        finalConfig = pkgs.writeText "actions.json" (builtins.toJSON configFile);
      };

      custom.shortcuts.hotkeys.keys = [
        {
          inherit (cfg.binding)
            key
            ctrl
            alt
            shift
            ;
          description = "Open the command palette";
          action = "${palette} --file ${cfg.finalConfig}";
        }
      ];
    };
}
