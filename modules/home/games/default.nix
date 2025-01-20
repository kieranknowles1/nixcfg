{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    ./factorio.nix
    ./openmw.nix
    ./skyrim
  ];

  options.custom.games = let
    inherit (lib) mkOption mkEnableOption types;
  in {
    enable = mkEnableOption "games";

    nexusModsKey = mkOption {
      type = types.str;
      description = ''
        Secret containing the API key for Nexus Mods.
      '';
      example = "nexusmods/apikey";
    };
  };

  config = let
    cfg = config.custom.games;
  in
    lib.mkIf cfg.enable {
      home.packages = with pkgs; [
        # Ignore do not use warning. We have the required dependencies
        # enabled host-side.
        steam

        # Need this for MO2 installer
        zenity

        wine
        winetricks
        protontricks # Proton itself is installed by steam

        # Launcher for Epic Games Store
        heroic

        # Minecraft launcher
        prismlauncher
      ];

      sops.secrets."nexusmods/apikey".key = cfg.nexusModsKey;
    };
}
