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

  flakePackages = flake.packages.${hostConfig.nixpkgs.hostPlatform.system};
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

    home.packages = with flakePackages; [
      skyrim-utils
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

      shortcuts = let
          utilsBin = "${flakePackages.skyrim-utils}/bin/skyrim-utils";
      in {
        "alt + shift + s" = {
          action = "${utilsBin} latest";
          description = "Open the latest Skyrim save in ReSaver";
        };
        "alt + shift + c" = {
          action = "${utilsBin} crash";
          description = "Open the most recent Skyrim crash log";
        };
      };
    };
  };
}
