{
  flake-parts-lib,
  lib,
  ...
}:
{
  options.flake =
    let
      inherit (flake-parts-lib) mkSubmoduleOptions;
      inherit (lib) mkOption types;
    in
    mkSubmoduleOptions {
      assets = mkOption {
        type = types.anything;
        default = { };
        description = "Third-party assets for the flake.";
      };
    };

  config.flake.assets =
    let
      fetchGitHub =
        {
          owner,
          repo,
          rev,
          hash,
        }:
        builtins.fetchTarball {
          url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
          sha256 = hash;
        };
    in
    {
      # Like these for generic icons
      mdi-icons = fetchGitHub {
        owner = "Templarian";
        repo = "MaterialDesign";
        # Master as of 19/12/24
        rev = "ce55b68ba7308fef54003d5c588343eeac30ff7a";
        hash = "sha256-S5EugaVJpFxLYM6s+Ujd8vyD6MUa+sxwQrBGTT+ve6w=";
      };

      # Brand icons that are deliberately excluded from the Material Design set
      simple-icons = fetchGitHub {
        owner = "simple-icons";
        repo = "simple-icons";
        rev = "13.21.0";
        hash = "sha256-hBb4jIGxdlNE/Om1cpPYHpw4YSD/kkYOdZpXr63wM+w=";
      };
    };
}
