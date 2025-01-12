{
  hostConfig,
  pkgs,
  lib,
  ...
}: let
  resaverDesktopFileName = "resaver.desktop";
in {
  config = lib.mkIf hostConfig.custom.games.enable {
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
        utilsBin = lib.getExe pkgs.flake.skyrim-utils;
        mkAction = subcommand: description: {
          action = [utilsBin subcommand];
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
