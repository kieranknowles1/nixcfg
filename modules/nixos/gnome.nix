# Global-user Gnome settings
# See also: ../home/gnome.nix
# TODO: Make the link clickable
{ pkgs, ...}:
{
  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Remove unneeded packages
  services.xserver.excludePackages = with pkgs; [
    xterm
  ];

  # TODO: Explain why each is unneeded. Anything that has been replaced should be removed in the replacement
  environment.gnome.excludePackages = with pkgs; [
    gnome-connections
    gnome-tour
    gnome.cheese # TODO: Why isnt this removed
    gnome.file-roller
    gnome.gnome-calendar
    gnome.gnome-clocks
    gnome.gnome-contacts
    gnome.gnome-maps
    gnome.gnome-weather
    gnome.simple-scan
    gnome.yelp
  ];
}
