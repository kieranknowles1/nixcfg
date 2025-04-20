{
  self,
  pkgs,
  inputs,
  ...
}: {
  config.custom = {
    # TODO: Can we cycle through wallpapers?
    theme.wallpaper = self.builders.${pkgs.stdenv.hostPlatform.system}.fromHeif ./wallpaper-2.heic;

    secrets = {
      ageKeyFile = "/home/kieran/.config/sops/age/keys.txt";
      file = ./secrets.yaml;
    };

    games = {
      factorio = {
        blueprints = "${inputs.factorio-blueprints}/blueprints";

        blueprints-repo = "/home/kieran/Documents/src/factorio-blueprints";

        configFile = {
          file = ./factorio.ini;
          repoPath = "users/kieran/factorio.ini";
        };
      };

      openmw = {
        globalStorage = {
          nix = ./openmw/global_storage.json;
          repo = "users/kieran/openmw/global_storage.json";
        };
        playerStorage = {
          nix = ./openmw/player_storage.json;
          repo = "users/kieran/openmw/player_storage.json";
        };
      };
    };
  };
}
