# Per-user Gnome settings
# See also: ../nixos/gnome.nix
# TODO: Make the link clickable
{ ... }:
{
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
  };
}
