{
  config,
  hostConfig,
  pkgs,
  flake,
  lib,
  ...
}: let
  applicationsDir = "${config.xdg.dataHome}/applications";

  resaverDesktopFileName = "nixcfg-resaver.desktop";

  skyrim-utils = "${flake.packages.${hostConfig.nixpkgs.hostPlatform.system}.skyrim-utils}/bin/skyrim-utils";
in {
  config = lib.mkIf hostConfig.custom.games.enable {
    # Install the desktop file to ~/.local/share/applications
    home.file."${applicationsDir}/${resaverDesktopFileName}".text = flake.lib.package.mkDesktopEntry {
      name = "ReSaver";
      description = "Skyrim and Fallout 4 savegame editor";
      # TODO: Don't hardcode the path to the executable and working directory
      command = "${pkgs.jdk21}/bin/java -jar /home/kieran/Games/modding-tools/resaver/target/ReSaver.jar %u";
      workingDirectory = "/home/kieran/Games/modding-tools/resaver/target";
    };

    home.packages = [
      skyrim-utils
    ];

    # Associate our mime types with the desktop file. See [[../../mime/default.nix]]
    xdg.mimeApps = {
      enable = true;

      associations.added = {
        "application/x-skyrimsave" = resaverDesktopFileName;
        "application/x-fallout4save" = resaverDesktopFileName;
      };
    };

    custom = {
      mime.definition = {
        "application/x-skyrimsave" = ./mime/application-x-skyrimsave.xml;
        "application/x-fallout4save" = ./mime/application-x-fallout4save.xml;
      };

      shortcuts = {
        "alt + shift + s" = {
          action = "${skyrim-utils} latest";
          description = "Open the latest Skyrim save in ReSaver";
        };
        "alt + shift + c" = {
          action = "${skyrim-utils} crash";
          description = "Open the most recent Skyrim crash log";
        };
      };
    };
  };
}
