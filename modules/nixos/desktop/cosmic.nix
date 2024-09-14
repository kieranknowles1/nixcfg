{
  config,
  lib,
  ...
}: let
  isCosmic = config.custom.desktop.environment == "cosmic";
in {
  config = lib.mkIf isCosmic {
    nix.settings = {
      substituters = ["https://cosmic.cachix.org/"];
      trusted-public-keys = ["cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="];
    };

    services.desktopManager.cosmic = {
      enable = true;

      xwayland.enable = true;
    };

    # TODO: Before making this the default, would like to make the following changes:
    # - Window view when pressing super, like in GNOME
    # - Manage config with nix
    # - Disable highlight of active window
    # - Fix alt-tab with fullscreen (maybe only an issue with xwayland?)
    # - Stylix support, to set wallpaper and disable flashbang on startup
  };
}
