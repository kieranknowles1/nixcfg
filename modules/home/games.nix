{ pkgs, config, ... }: let
  applicationsDir = "${config.xdg.dataHome}/applications";

  resaverDesktop = {
    fileName = "nixcfg-resaver.desktop";
    # TODO: Don't hardcode the path to the desktop file
    contents = ''
      [Desktop Entry]
      Type=Application
      Version=1.0
      Name=ReSaver
      Comment=Skyrim and Fallout 4 savegame editor
      Path=/home/kieran/Games/modding-tools/resaver/target
      MimeType=application/x-skyrimsave;
      Exec=${pkgs.jdk21}/bin/java -jar /home/kieran/Games/modding-tools/resaver/target/ReSaver.jar %u
    '';
  };
in {
  # TODO: Condition this based on the host's configuration
  config = {
    # Install the desktop file to ~/.local/share/applications
    home.file."${applicationsDir}/${resaverDesktop.fileName}".text = resaverDesktop.contents;

    # Associate our mime types with the desktop file. See ./mime/
    # TODO: Make the link clickable
    xdg.mimeApps = {
      enable = true;

      associations.added = {
        "application/x-skyrimsave" = resaverDesktop.fileName;
        "application/x-fallout4save" = resaverDesktop.fileName;
      };
    };
  };
}
