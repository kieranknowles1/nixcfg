{ config, pkgs-unstable, ... }:
let
  settings-root = "${config.xdg.configHome}/Code/User";
in
{
  config = {
    programs.vscode = {
      enable = true;
      extensions = with pkgs-unstable.vscode-extensions; [
        github.copilot
        github.copilot-chat
        gruntfuggly.todo-tree
        jnoortheen.nix-ide
        redhat.vscode-yaml
      ];
    };

    # TODO: Find a way that I can still edit and sync back
    # to the repo later
    home.file."${settings-root}/settings.json" = {
      source = ./settings.json;
    };
  };
}
