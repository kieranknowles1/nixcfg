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

    # Give the full set of titlebar buttons
    "org/gnome/desktop/wm/preferences" = {
      "button-layout" = "appmenu:minimize,maximize,close";
    };
  };
}