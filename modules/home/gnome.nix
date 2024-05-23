# Per-user Gnome settings
# See also: ../nixos/gnome.nix
# TODO: Make the link clickable
{ ... }:
{
  dconf.settings = {
    "org/gnome/mutter" = {
      # Snap windows to screen edges
      "edge-tiling" = true;
    };
  };
}