# Module to install game tools
{ config, lib, pkgs-unstable, pkgs, ... }: let
  # TODO: Don't like this hardcoded path, but ReSaver is only hosted on Nexus Mods which I'd have to pass my API key to download from
  resaverJar = /home/kieran/Games/modding-tools/resaver/target/ReSaver.jar;

  resaverDesktop = pkgs.makeDesktopItem {
    name = "resaver-desktop";
    desktopName = "ReSaver";
    # We use %f to pass the opened file as the first argument
    exec = "${pkgs.jre8} -jar ${resaverJar} %f";
  };
in {
  options = {
    custom.games.enable = lib.mkEnableOption "games";
  };

  config = lib.mkIf config.custom.games.enable {
    programs.steam.enable = true;

    # Run proton on the bleeding edge as it is updated frequently
    environment.systemPackages = with pkgs-unstable; [
      protontricks # Proton itself is installed by steam
    ];
  };
}
