# Per-user Gnome settings
# See also: [[../nixos/gnome.nix]]
{
  hostConfig,
  lib,
  ...
}: {
  config = lib.mkIf (hostConfig.custom.desktop.environment == "gnome") {
    # HACK: Workaround for opening URLs through sandboxed apps not working.
    # Foribly restart xdg-desktop-portal shortly after login which seems to
    # fix the issue until reboot.
    xsession.initExtra = ''
      sleep 5s && systemctl --user restart xdg-desktop-portal.service &
    '';
    dconf.settings = {
      # Snap windows to screen edges
      "org/gnome/mutter" = {
        "edge-tiling" = true;
      };

      # Disable the annoying "hot corner" that shows the overview
      "org/gnome/desktop/interface" = {
        "enable-hot-corners" = false;
      };

      # Give the full set of titlebar buttons
      "org/gnome/desktop/wm/preferences" = {
        "button-layout" = "appmenu:minimize,maximize,close";
      };

      # Enable tap to click on touchpads
      "org/gnome/desktop/peripherals/touchpad" = {
        "tap-to-click" = true;
      };
    };
  };
}
