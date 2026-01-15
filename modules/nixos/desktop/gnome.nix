# Global-user Gnome settings
# See also: [[../home/gnome.nix]]
{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf (config.custom.desktop.enable && (config.custom.desktop.environment == "gnome")) {
    # Enable the GNOME Desktop Environment.
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;

    # Remove unneeded packages
    services.xserver.excludePackages = with pkgs; [
      xterm
    ];

    services.gnome = {
      gnome-initial-setup.enable = false; # Redundant with NixOS
    };

    # TODO: Consider not having any of GNOME's default apps installed, and be explicit about what I want.
    environment.gnome.excludePackages = with pkgs; [
      papers # Firefox can handle PDFs
      showtime # VLC is better for videos
      gnome-console # Managed by home-manager
      gnome-connections # I have no need for remote desktop
      gnome-tour # Basic intro to GNOME
      gnome-text-editor # Use an IDE instead
      # NOTE: This is a dependency of gnome-control-center, so it isn't really removed.
      # While removing it would be the Nix way, it's too useful for finding what to do in the first place.
      cheese # I don't have a webcam.
      file-roller # Nautilus can handle archives
      gnome-calendar # I use my phone for calendar
      gnome-clocks # I use my phone for alarms
      gnome-contacts # I use my phone for contacts
      # gnome-control-center # Settings are managed by NixOS, but this is good for discovery
      gnome-font-viewer # I just use the font dialog in apps
      gnome-maps # I use my phone for maps
      gnome-music # Not using this
      gnome-shell-extensions # Not using any of these
      gnome-software # It's not sideloading, it's installing software
      gnome-system-monitor # I use Resouces
      gnome-weather # I use my phone for weather
      simple-scan # My scandoc script does this better for my requirements
      totem # Video player. Use VLC instead
      yelp # I use the web for documentation
      snapshot # I don't have a webcam
    ];

    environment.systemPackages = with pkgs; [
      resources
    ];
  };
}
