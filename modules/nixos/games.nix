# Module to install game tools
{ config, lib, pkgs-unstable, ... }:
{
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
