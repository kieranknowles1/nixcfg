{
  config,
  pkgs,
  lib,
  ...
}: let
  resaverDesktopFileName = "resaver.desktop";

  utilsBin = lib.getExe pkgs.flake.skyrim-utils;
in {
  config = lib.mkIf config.custom.games.enable {
    home.packages = [
      pkgs.flake.resaver
    ];

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
        mkAction = subcommand: description: {
          action = [utilsBin subcommand];
          description = "Skyrim: ${description}";
        };
      in [
        (mkAction "latest" "Open the latest save in ReSaver")
        (mkAction "crash" "Open the most recent crash log")
      ];

      timer."clean-skyrim-saves" = {
        description = "Clean orphaned SKSE co-save files";
        schedule = "daily";
        command = "${utilsBin} clean";
      };
    };
  };
}
