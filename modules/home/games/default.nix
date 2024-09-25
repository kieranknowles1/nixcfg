{
  pkgs,
  lib,
  config,
  hostConfig,
  ...
}: {
  imports = [
    ./factorio
    ./openmw
    ./skyrim
  ];

  options.custom.games = {
    nexusModsKey = lib.mkOption {
      type = lib.types.str;
      description = ''
        Secret containing the API key for Nexus Mods.
      '';
      example = "nexusmods/apikey";
    };
  };

  config = lib.mkIf hostConfig.custom.games.enable {
    home.packages = with pkgs; [
      # Minecraft launcher
      prismlauncher
    ];

    sops.secrets."nexusmods/apikey".key = config.custom.games.nexusModsKey;
  };
}
