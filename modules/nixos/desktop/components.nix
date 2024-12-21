# Common components shared between desktop environments
{
  pkgs,
  ...
}: {
  config.environment = {
    # Nautilus has been acting up lately, plus it struggles with large directories
    # and isn't to my liking. Thunar meets my one requirement: it's fast. Nautilus
    # takes 1sec to open a directory with 150 files, Thunar can do 2000 in 100ms.
    gnome.excludePackages = with pkgs; [
      nautilus
    ];
    systemPackages = with pkgs; [
      xfce.thunar
      xfce.xfconf
    ];
  };
}
