{
  self,
  pkgs,
  inputs,
  ...
}: {
  config.custom = let
    serverConfig = self.nixosConfigurations.tycho.config;
    cfgs = serverConfig.custom.server;
  in {
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
          nix = ./openmw/global_storage.ron;
          repo = "users/kieran/openmw/global_storage.ron";
        };
        playerStorage = {
          nix = ./openmw/player_storage.ron;
          repo = "users/kieran/openmw/player_storage.ron";
        };
      };
    };

    office.paperless.url = "https://${cfgs.paperless.subdomain}.${cfgs.hostname}";
  };
}
