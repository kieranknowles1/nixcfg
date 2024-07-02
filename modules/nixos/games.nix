# Module to install game tools
{
  config,
  lib,
  pkgs-unstable,
  pkgs,
  flake,
  system,
  ...
}: let
  flakePackages = flake.packages.${system};
in {
  options = {
    custom.games.enable = lib.mkEnableOption "games";
  };

  config = lib.mkIf config.custom.games.enable {
    programs.steam.enable = true;

    # Run proton and wine on the bleeding edge as they are updated frequently
    environment.systemPackages = with pkgs-unstable; [
      zenity # Need this for MO2 installer

      # Windows dependencies can be installed to a wine prefix using winetricks.
      # If an installer says to restart Windows, restarting wine should be enough.
      wine
      winetricks
      protontricks # Proton itself is installed by steam

      openmw # TODO: Get my own version building. May be time to learn dev shells

      # Game tools
      flakePackages.clean-skse-cosaves

      # Launcher for Epic Games Store
      heroic
    ];
  };
}
