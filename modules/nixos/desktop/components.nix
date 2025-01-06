# Common components shared between desktop environments
{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.custom.features.desktop {
    # Nautilus has been acting up lately, plus it struggles with large directories
    # and isn't to my liking. Thunar meets my one requirement: it's fast. Nautilus
    # takes 1sec to open a directory with 150 files, Thunar can do 2000 in 100ms.
    environment = {
      gnome.excludePackages = with pkgs; [
        nautilus
      ];
      systemPackages = with pkgs; [
        # TODO: Opening terminal doesn't work
        # TODO: Why does this replace our removal of the extra .desktop files?
        (xfce.thunar.override {
          thunarPlugins = [
            xfce.thunar-archive-plugin
          ];
        })
        # thunar-archive-plugin requires an archive manager
        ark
        xfce.xfconf
      ];
    };

    xdg.mime.addedAssociations = {
      "inode/directory" = "thunar.desktop";
      # Prism (Minecraft launcher) associates itself with zips
      # Make sure our archive manager has priority
      "application/zip" = "org.kde.ark.desktop";
    };
  };
}
