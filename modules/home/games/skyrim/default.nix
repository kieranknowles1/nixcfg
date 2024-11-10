{
  config,
  hostConfig,
  pkgs,
  self,
  lib,
  ...
}: let
  applicationsDir = "${config.xdg.dataHome}/applications";

  resaverDesktopFileName = "nixcfg-resaver.desktop";
in {
  config = lib.mkIf hostConfig.custom.games.enable {
    # Install the desktop file to ~/.local/share/applications
    home.file."${applicationsDir}/${resaverDesktopFileName}".text = self.lib.package.mkDesktopEntry {
      name = "ReSaver";
      description = "Skyrim and Fallout 4 savegame editor";
      # %u is a placeholder. When double-clicking a file, it will be replaced with the file's path
      command = "${lib.getExe pkgs.flake.resaver} %u";
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
        mkAction = subcommand: description: {
          action = [ utilsBin subcommand ];
          description = "Skyrim: ${description}";
        };
      in [
        (mkAction "latest" "Open the latest save in ReSaver")
        (mkAction "crash" "Open the most recent crash log")
        (mkAction "clean" "Clean orphaned SKSE co-save files")
      ];
    };
  };
}
