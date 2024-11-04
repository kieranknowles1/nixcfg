{
  pkgs,
  inputs,
  hostConfig,
  ...
}: {
  config.custom = {
    theme.wallpaper = pkgs.flake.lib.image.fromHeif ./wallpaper.heic;

    secrets = {
      ageKeyFile = "/home/kieran/.config/sops/age/keys.txt";
      file = ./secrets.yaml;
    };

    games = {
      factorio.blueprints = "${inputs.factorio-blueprints}/blueprints";

      openmw = {
        globalStorage = ./openmw/global_storage.json;
        playerStorage = ./openmw/player_storage.json;
      };

      factorio.configFile = {
        file = ./factorio.ini;
        repoPath = "users/kieran/factorio.ini";
      };
    };

    trilium-client.enable = hostConfig.networking.hostName == "canterbury";
  };
}
