{
  lib,
  config,
  hostConfig,
  ...
}: {
  imports = [
    ./hotkeys.nix
    ./palette.nix
  ];

  options.custom.shortcuts = {
    enable = lib.mkEnableOption "keyboard shortcuts and command palettes";
  };

  config = let
    cfg = config.custom.shortcuts;
  in
    lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = hostConfig.custom.features.desktop;
          message = "Keyboard shortcuts require a desktop environment.";
        }
      ];
    };
}
