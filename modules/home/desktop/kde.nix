{
  lib,
  hostConfig,
  ...
}: {
  config = lib.mkIf (hostConfig.custom.desktop.environment == "kde") {
    custom.shortcuts.hotkeys.keys = {
      "Super_L" = {
        action = "krunner";
        description = "Application runner";
      };
    };
  };
}
