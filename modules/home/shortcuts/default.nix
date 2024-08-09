{lib, config, hostConfig, ...}: {
  imports = [
    ./hotkeys.nix
    ./palette.nix
  ];

  options.custom.shortcuts = {
    enable = lib.mkEnableOption "keyboard shortcuts and command palettes";
  };

  config = let
    cfg = config.custom.shortcuts;
  in lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = hostConfig.custom.deviceType == "desktop";
        message = "Keyboard shortcuts are only available on desktop devices";
      }
    ];
  };
}
