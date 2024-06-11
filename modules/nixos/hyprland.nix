{
  pkgs,
  ...
}: {
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  environment.systemPackages = with pkgs; [
    waybar

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
  # xdg.portal = {
  #   enable = true;
  #   extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  # };
}
