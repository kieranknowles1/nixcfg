# Module to install game tools
{
  config,
  lib,
  pkgs,
  ...
}: {
  # TODO: MOve to home-manager
  options = {
    custom.games.enable = lib.mkEnableOption "games";
  };

  config = lib.mkIf config.custom.games.enable {
    programs.steam.enable = true;

    environment.systemPackages = with pkgs; [
      zenity # Need this for MO2 installer

      # Windows dependencies can be installed to a wine prefix using winetricks.
      # If an installer says to restart Windows, restarting wine should be enough.
      wine
      winetricks
      protontricks # Proton itself is installed by steam

      # Launcher for Epic Games Store
      heroic
    ];
  };
}
