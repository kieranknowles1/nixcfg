{ pkgs, lib, config, hostConfig, ... }: let
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
  config = lib.mkIf hostConfig.custom.games.enable {
    # Install the desktop file to ~/.local/share/applications
    home.file."${applicationsDir}/${resaverDesktop.fileName}".text = resaverDesktop.contents;

    # Associate our mime types with the desktop file. See [[./mime/default.nix]]
    xdg.mimeApps = {
      enable = true;

      associations.added = {
        "application/x-skyrimsave" = resaverDesktop.fileName;
        "application/x-fallout4save" = resaverDesktop.fileName;
      };
    };
  };
}
