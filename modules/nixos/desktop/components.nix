# Common components shared between desktop environments
{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.custom.desktop.enable {
    # Nautilus has been acting up lately, plus it struggles with large directories
    # and isn't to my liking. Thunar meets my one requirement: it's fast. Nautilus
    # takes 1sec to open a directory with 150 files, Thunar can do 2000 in 100ms.
    environment = {
      gnome.excludePackages = with pkgs; [
        nautilus
      ];
      systemPackages = with pkgs; [
        xfce.thunar
        xfce.xfconf
        flake.extract
      ];
    };

    xdg.mime.addedAssociations = {
      "inode/directory" = "thunar.desktop";
      # Prism (Minecraft launcher) associates itself with zips
      # Make sure our archive manager has priority
      "application/zip" = "extract.desktop";
    };

    security.wrappers.swhkd = {
      setuid = true;
      owner = "root";
      group = "root";
      source = "${pkgs.flake.swhkd}/bin/swhkd";
    };
  };
}
