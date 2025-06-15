{
  lib,
  config,
  ...
}: {
  config = lib.mkIf (config.custom.features.desktop && (config.custom.desktop.environment == "kde")) {
    services = {
      xserver.enable = true;
      displayManager = {
        sddm.enable = true;
        sddm.wayland.enable = true;
      };
      desktopManager.plasma6.enable = true;
    };
  };
}
