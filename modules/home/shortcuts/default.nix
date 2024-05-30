# Keyboard shortcuts managed by AutoKey
{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    autokey
  ];

  home.file."${config.xdg.configHome}/autokey/data" = {
    source = ./data;
    recursive = true;
  };
}
