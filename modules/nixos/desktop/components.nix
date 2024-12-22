# Common components shared between desktop environments
{pkgs, ...}: let
  thunar-onedesktop = pkgs.xfce.thunar.overrideAttrs (_oldAttrs: {
    postFixup = ''
      # Remove the .desktop files for bulk rename and settings to reduce clutter
      rm $out/share/applications/thunar-bulk-rename.desktop
      rm $out/share/applications/thunar-settings.desktop
    '';
  });
in {
  config = {
    # Nautilus has been acting up lately, plus it struggles with large directories
    # and isn't to my liking. Thunar meets my one requirement: it's fast. Nautilus
    # takes 1sec to open a directory with 150 files, Thunar can do 2000 in 100ms.
    environment = {
      gnome.excludePackages = with pkgs; [
        nautilus
      ];
      systemPackages = with pkgs; [
        thunar-onedesktop
        xfce.xfconf
      ];
    };

    xdg.mime.addedAssociations = {
      "inode/directory" = "thunar.desktop";
    };
  };
}
