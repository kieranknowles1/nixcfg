# Module to install game tools
{ config, lib, pkgs-unstable, pkgs, ... }:
{
  options = {
    custom.games.enable = lib.mkEnableOption "games";
  };

  config = lib.mkIf config.custom.games.enable {
    programs.steam.enable = true;

    # Run proton and wine on the bleeding edge as they are updated frequently
    environment.systemPackages = with pkgs-unstable; [
      pkgs.gnome.zenity # Need this for MO2 installer

      wine
      winetricks
      protontricks # Proton itself is installed by steam

      openmw # TODO: Get my own version building. May be time to learn dev shells
    ];
  };
}
