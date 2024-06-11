{
  pkgs,
  inputs,
  system,
  ...
}: {
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    package  = inputs.hyprland.packages.${system}.hyprland;
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
