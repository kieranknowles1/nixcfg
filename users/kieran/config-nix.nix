{pkgs, ...}: {
  config.custom = {
    theme.wallpaper = pkgs.flake.lib.image.fromHeif ./wallpaper.heic;

    secrets = {
      ageKeyFile = "/home/kieran/.config/sops/age/keys.txt";
      file = ./secrets.yaml;
    };

    games.openmw = {
      globalStorage = ./openmw/global_storage.json;
      playerStorage = ./openmw/player_storage.json;
    };
  };
}