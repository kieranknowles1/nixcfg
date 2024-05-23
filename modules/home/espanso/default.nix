{ config, ... }:
let
  settings-root = "${config.xdg.configHome}/espanso";
in
{
  services.espanso = {
    enable = true;
    # Don't manage configs here, we'll do that ourselves
    configs = {};
    matches = {};
  };

  # Provision with home-manager so we can use yaml directly
  home.file."${config.xdg.configHome}/espanso/" = {
    source = ./config;
    recursive = true;
  };
}
