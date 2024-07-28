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
    command = lib.strings.escapeShellArg action.command;
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
      # TODO: Use a more specific type
      type = lib.types.listOf lib.types.attrs;
    };
  };

  config = lib.mkIf config.custom.shortcuts.enable {
    home.packages = [
      flake.packages.${hostConfig.nixpkgs.hostPlatform.system}.command-palette
    ];

    custom.shortcuts.hotkeys.keys = {
      "alt + shift + p" = {
        description = "Open the command palette";
        action = "${package} ${actions}";
      };
    };
  };
}
