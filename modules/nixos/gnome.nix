{ config, pkgs, ...}:
{
  # TODO: Move rest of GNOME here

  # Remove unneeded packages
  services.xserver.excludePackages = with pkgs; [
    xterm
  ];

  # TODO: Make sure this is sorted and explain why each is unneeded
  environment.gnome.excludePackages = with pkgs; [
    evince
    gnome.cheese # TODO: Why isnt this removed
    gnome.simple-scan
    epiphany
    gnome-connections
    gnome.gnome-calendar
    gnome.file-roller
    gnome.gnome-clocks
    gnome-tour
    gnome.gnome-contacts
    gnome.gnome-maps
    gnome.yelp
    gnome.gnome-weather
  ];
}
