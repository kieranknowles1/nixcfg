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
in {
  config = lib.mkIf hostConfig.custom.games.enable {
    # Install the desktop file to ~/.local/share/applications
    home.file."${applicationsDir}/${resaverDesktopFileName}".text = flake.lib.package.mkDesktopEntry {
      name = "ReSaver";
      description = "Skyrim and Fallout 4 savegame editor";
      # TODO: Don't hardcode the path to the executable and working directory
      # TODO: Fetch from Nexus with my API key (use SOPS to encrypt it)
      command = "${pkgs.jdk21}/bin/java -jar /home/kieran/Games/modding-tools/resaver/target/ReSaver.jar %u";
      workingDirectory = "/home/kieran/Games/modding-tools/resaver/target";
    };

    custom = {
      mime.definition = {
        "application/x-skyrimsave" = {
          definitionFile = ./mime/application-x-skyrimsave.xml;
          defaultApp = resaverDesktopFileName;
        };
        "application/x-fallout4save" = {
          definitionFile = ./mime/application-x-fallout4save.xml;
          defaultApp = resaverDesktopFileName;
        };
      };

      shortcuts.palette.actions = let
        utilsBin = lib.getExe pkgs.flake.skyrim-utils;
        utils = command: [utilsBin command];
      in [
        {
          action = utils "latest";
          description = "Skyrim: Open the latest save in ReSaver";
        }
        {
          action = utils "crash";
          description = "Skyrim: Open the most recent crash log";
        }
        {
          action = utils "clean";
          description = "Skyrim: Clean orphaned SKSE co-save files";
        }
      ];
    };
  };
}
