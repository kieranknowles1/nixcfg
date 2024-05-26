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

  environment.gnome.excludePackages = with pkgs; [
    gedit # Replaced by vscode, but that is managed by home-manager
    gnome-connections # I have no need for remote desktop
    gnome-tour # Basic intro to GNOME
    gnome.cheese # TODO: Why isnt this removed
    gnome.file-roller # Nautilus can handle archives
    gnome.gnome-calendar # I use my phone for calendar
    gnome.gnome-clocks # I use my phone for alarms
    gnome.gnome-contacts # I use my phone for contacts
    gnome.gnome-maps # I use my phone for maps
    gnome.gnome-weather # I use my phone for weather
    gnome.simple-scan # I have no scanner
    gnome.yelp # I use the web for documentation
  ];
}
