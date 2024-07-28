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

  utilsBin = "${flakePackages.skyrim-utils}/bin/skyrim-utils";
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

      shortcuts.palette.actions = [
        {
          command = "${utilsBin} latest";
          description = "Open the latest save in ReSaver";
        }
        {
          command = "${utilsBin} crash";
          description = "Open the most recent crash log";
        }
        {
          command = "${utilsBin} clean";
          description = "Clean orphaned SKSE co-save files";
        }
      ];
      # shortcuts.hotkeys.keys = let
      #   utilsBin = "${flakePackages.skyrim-utils}/bin/skyrim-utils";
      #   zenity = "${pkgs.zenity}/bin/zenity";

      #   # Couldn't find an easy way to do a select dialog in Rust,
      #   # So I'm using Zenity to create a dialog.
      #   # TODO: Move this to a generic command palette option
      #   selectAction = pkgs.writeShellScriptBin "skyrim-utils-select" ''
      #     set -e

      #     choice=$(${zenity} --list --column=Action --column=Description --hide-header --title="Skyrim Utils" --text="Select an action" \
      #       latest "Open the latest save in ReSaver" \
      #       crash "Open the most recent crash log" \
      #       clean "Clean orphaned SKSE co-save files" \
      #     )

      #     stdout=$(${utilsBin} "$choice")

      #     # Display the output of the command in a dialog if any
      #     if [ ! -z "$stdout" ]; then
      #       ${zenity} --info --text="$stdout"
      #     fi
      #   '';
      # in {
      #   "alt + shift + s" = {
      #     description = "Run a Skyrim utility";
      #     action = "${selectAction}/bin/skyrim-utils-select";
      #   };
      # };
    };
  };
}
