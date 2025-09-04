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
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;

    # Remove unneeded packages
    services.xserver.excludePackages = with pkgs; [
      xterm
    ];

    services.gnome = {
      gnome-initial-setup.enable = false; # Redundant with NixOS
    };

    # TODO: Consider not having any of GNOME's default apps installed, and be explicit about what I want.
    environment.gnome.excludePackages = with pkgs; [
      # GNOME's built-in browser
      epiphany
      gnome-console # Managed by home-manager
      # GNOME's document viewer. Firefox does a better job at this
      evince
      gedit # Replaced by vscode, but that is managed by home-manager
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
      gnome-system-monitor # I use Resouces
      gnome-weather # I use my phone for weather
      simple-scan # I have no scanner
      totem # Video player. Use VLC instead
      yelp # I use the web for documentation
      snapshot # I don't have a webcam
    ];

    environment.systemPackages = with pkgs; [
      resources
    ];
  };
}
