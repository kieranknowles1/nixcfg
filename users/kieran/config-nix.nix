{pkgs, ...}: {
  config.custom = {
    theme.wallpaper = pkgs.flake.lib.image.fromHeif ./wallpaper.heic;

    secrets = {
      ageKeyFile = "/home/kieran/.config/sops/age/keys.txt";
      file = ./secrets.yaml;
    };

    games = {
      # TODO: Move this to its own repository, the files are quite large and add a download
      # when using the flake as a dependency.
      # Currently, including export-blueprints would cause a circular dependency, so we
      # need to also move our packages/lib to its own repository, which would make maintaining
      # the flake more difficult.
      factorio.blueprints = ./factorio-blueprints;

      openmw = {
        globalStorage = ./openmw/global_storage.json;
        playerStorage = ./openmw/player_storage.json;
      };
    };
  };
}
