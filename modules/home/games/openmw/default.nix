{
  pkgs,
  hostConfig,
  lib,
  ...
}: {
  config = lib.mkIf hostConfig.custom.games.enable {
    home.packages = with pkgs; [
      flake.openmw-dev
    ];
  };
}
