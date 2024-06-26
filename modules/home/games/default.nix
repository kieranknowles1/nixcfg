{
  pkgs,
  lib,
  config,
  hostConfig,
  flake,
  ...
}: let
  applicationsDir = "${config.xdg.dataHome}/applications";

  resaverDesktopFileName = "nixcfg-resaver.desktop";
in {
  imports = [
    ./factorio
  ];

  config = lib.mkIf hostConfig.custom.games.enable {
    # Install the desktop file to ~/.local/share/applications
    home.file."${applicationsDir}/${resaverDesktopFileName}".text = flake.lib.package.mkDesktopEntry {
      name = "ReSaver";
      description = "Skyrim and Fallout 4 savegame editor";
      # TODO: Don't hardcode the path to the executable and working directory
      command = "${pkgs.jdk21}/bin/java -jar /home/kieran/Games/modding-tools/resaver/target/ReSaver.jar %u";
      workingDirectory = "/home/kieran/Games/modding-tools/resaver/target";
    };

    # Associate our mime types with the desktop file. See [[../mime/default.nix]]
    xdg.mimeApps = {
      enable = true;

      associations.added = {
        "application/x-skyrimsave" = resaverDesktopFileName;
        "application/x-fallout4save" = resaverDesktopFileName;
      };
    };

    systemd.user.sessionVariables = {
      # Use Wayland instead of XWayland for Factorio and probably other games.
      # https://www.factorio.com/blog/post/fff-408
      SDL_VIDEODRIVER = "wayland";
    };

    home.packages = with pkgs; [
      # Minecraft launcher
      prismlauncher
    ];
  };
}
