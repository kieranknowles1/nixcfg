{
  pkgs,
  lib,
  hostConfig,
  ...
}: {
  imports = [
    ./factorio
    ./skyrim.nix
  ];

  config = lib.mkIf hostConfig.custom.games.enable {
    home.packages = with pkgs; [
      # Minecraft launcher
      prismlauncher
    ];
  };
}
