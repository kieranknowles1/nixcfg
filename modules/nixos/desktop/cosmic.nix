{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf (config.custom.desktop.enable && (config.custom.desktop.environment == "cosmic")) {
    services.desktopManager.cosmic = {
      enable = true;

      xwayland.enable = true;

      # TODO: Choose which default apps to exclude. Current shortlist
      # cosmic-files: Fast, but not as fast as Thunar, doesn't quite meet my (very high) standards here
    };

    services.displayManager.cosmic-greeter.enable = true;

    environment.cosmic.excludePackages = with pkgs; [
      cosmic-store # Use Nix to install packages
    ];

    # TODO: Before making this the default, would like to make the following changes:
    # [ ] Window view when pressing super, like in GNOME
    # [ ] Manage config with nix
    # [ ] Manage wallpaper with nix
    # [ ] Disable highlight of active window
    # [ ] Fix alt-tab with fullscreen (maybe only an issue with xwayland?)
    # [ ] Stylix support to set wallpaper
    # [ ] Keyboard shortcuts (ideally without having to change too much)
    # [ ] Applications - automatically pick first when pressing enter
    # [ ] Alt+F4 support
    # [ ] Applications - scroll speed that matches rest of system (smells like a bug)
  };
}
