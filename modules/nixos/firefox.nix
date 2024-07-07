# System level Firefox settings
# See also: [[../home/firefox.nix]]
{pkgs, ...}: {
  environment.gnome.excludePackages = with pkgs; [
    # GNOME's built-in browser
    epiphany
    # GNOME's document viewer. Firefox does a better job at this
    evince
  ];
}
