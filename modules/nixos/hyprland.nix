# Hyprland desktop environment
# See also: [[../home/hyprland.nix]]
# TODO: Remove GNOME
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
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      package  = inputs.hyprland.packages.${system}.hyprland;
    };

    # TODO: Think most of this can be done without installign system-wide
    environment.systemPackages = with pkgs; [
      # Notification daemon
      mako

      # Wallpaper daemon
      swww

      # App launcher
      rofi-wayland

      # Dependency of mako
      libnotify
    ];

    # The desktop portal handles a bunch of stuff
    # TODO: What does this do?
    # TODO: Uncomment once I can build with it enabled
    # xdg.portal = {
    #   enable = true;
    #   extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    # };
  };
}
