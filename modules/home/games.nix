{ pkgs, config, ... }: let
  applicationsDir = "${config.xdg.dataHome}/applications";

  # TODO: Don't hardcode the path to the desktop file
  resaverDesktopContents = ''
    [Desktop Entry]
    Type=Application
    Version=1.0
    Name=ReSaver
    Comment=Skyrim and Fallout 4 savegame editor
    Path=/home/kieran/Games/modding-tools/resaver/target
    MimeType=application/x-skyrimsave;
    Exec=java -jar /home/kieran/Games/modding-tools/resaver/target/ReSaver.jar %u
  '';
in {
  # Install the desktop file to ~/.local/share/applications
  # TODO: Condition this based on the host's configuration
  home.file."${applicationsDir}/nixcfg-resaver.desktop".text = resaverDesktopContents;
}
