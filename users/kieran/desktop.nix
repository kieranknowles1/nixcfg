# Overrides to enable on desktop hosts
{
  hostConfig,
  lib,
  self,
  pkgs,
  inputs,
  ...
}: {
  config.custom = let
    cfgs = self.nixosConfigurations.tycho.config.custom.server;
  in
    lib.mkIf hostConfig.custom.desktop.enable {
      # TODO: Can we cycle through wallpapers?
      theme.wallpaper = self.builders.${pkgs.stdenv.hostPlatform.system}.fromHeif ./wallpaper-2.heic;

      docs-generate.install = true;
      discord.enable = true;

      telly.enable = true;

      espanso = {
        enable = true;

        packages = {
          misspell-en = {
            url = "https://github.com/timorunge/espanso-misspell-en/archive/refs/heads/master.tar.gz";
            hash = "sha256:1g3rd60jcqij5zhaicgcp73z31yfc3j4nbd29czapbmxjv3yi8yy";
            dir = "misspell-en/0.1.2";
          };
          misspell-en-uk = {
            url = "https://github.com/timorunge/espanso-misspell-en/archive/refs/heads/master.tar.gz";
            hash = "sha256:1g3rd60jcqij5zhaicgcp73z31yfc3j4nbd29czapbmxjv3yi8yy";
            dir = "misspell-en_UK/0.1.2";
          };
          contractions-en = {
            url = "https://github.com/sonofhypnos/espanso-contractions-en/archive/refs/heads/master.tar.gz";
            hash = "sha256:0pzizhp7p8xqjy1yprfjjyzdgjnsnkxrpv3gy1yrzx363gl0f3d5";
            dir = "contractions-en/0.1.0";
            # This conflicts with the word "cause" and I've never seen "’cause" used.
            removals = ["cause"];
            # Use the more common \u0027 apostrophe instead of \u2019 right single quotation mark
            replacements."’" = "'";
          };
        };
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

        nexusModsKey = "nexusmods/apikey";
      };

      office.paperless.url = "https://${cfgs.paperless.subdomain}.${cfgs.hostname}";

      shortcuts = {
        hotkeys.enable = true;
        hotkeys.visualiser.enable = true;
        palette.enable = true;
      };

      editor = {
        enable = true;
        default = "zed";
        vscode.enable = true;
        zed.enable = true;
      };
    };
}
