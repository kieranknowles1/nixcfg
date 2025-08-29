{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.custom.discord.enable = lib.mkEnableOption "Discord";

  config = lib.mkIf config.custom.discord.enable {
    home.packages = with pkgs; [
      discord
    ];
  };
}
