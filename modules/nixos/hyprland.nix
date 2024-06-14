# Hyprland desktop environment
# NOTE: Some modules still reference GNOME, but this becomes a no-op as we don't install GNOME
# See also: [[../home/hyprland/default.nix]]
{
  pkgs,
  inputs,
  lib,
  system,
  ...
}: {
  options.custom.hyprland = {
    # This is is used in the user config, but is a host specific setting so defined here
    monitors = lib.mkOption {
      description = ''
        The list of monitors to enable
        See [Hyprland Wiki](https://wiki.hyprland.org/Configuring/Monitors/)
      '';

      type = lib.types.listOf lib.types.str;
    };
  };

  config = {
    # Login manager, compatible with any desktop environment
    # Without this, we would have to log in via the terminal
    services.xserver.displayManager.gdm.enable = true;

    # TODO: Is this necessary with home-manager installing this?
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      package  = inputs.hyprland.packages.${system}.hyprland;
    };

    # TODO: Think most of this can be done without installign system-wide
    environment.systemPackages = with pkgs; [
      # Terminal
      kitty

      # File manager
      gnome.nautilus

      # Notification daemon
      mako

      # Dependency of mako
      libnotify

      # TypeScript runtime
      bun

      # Task manager
      resources
    ];

    # The desktop portal handles a bunch of stuff
    # TODO: What? You can't just say "a bunch of stuff"
    # TODO: Uncomment once I can build with it enabled
    # xdg.portal = {
    #   enable = true;
    #   extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    # };
  };
}
