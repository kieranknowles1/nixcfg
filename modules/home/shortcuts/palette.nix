{
  lib,
  config,
  hostConfig,
  flake,
  ...
}: let
  # TODO: Proper option for this
  package = "command-palette";

  toArgs = action: let
    command = lib.strings.escapeShellArg action.action;
    description = lib.strings.escapeShellArg action.description;
  in "${command} ${description}";

  actionArgs = builtins.map toArgs config.custom.shortcuts.palette.actions;
  actions = builtins.concatStringsSep " " actionArgs;
in {
  options.custom.shortcuts.palette = {
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
    home.packages = [
      flake.packages.${hostConfig.nixpkgs.hostPlatform.system}.command-palette
    ];

    custom.shortcuts.hotkeys.keys = {
      # TODO: Make the binding configurable
      "alt + shift + p" = {
        description = "Open the command palette";
        action = "${package} ${actions}";
      };
    };
  };
}
