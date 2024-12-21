{
  pkgs,
  ...
}: {
  config.environment = {
    # Nautilus has been acting up lately, plus it struggles with large directories
    # and isn't to my liking. Thunar meets my one requirement: it's fast.
    gnome.excludePackages = with pkgs; [
      nautilus
    ];
    systemPackages = with pkgs; [
      xfce.thunar
      xfce.xfconf
    ];
  };
}
