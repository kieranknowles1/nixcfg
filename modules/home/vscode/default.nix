{ config, pkgs, ... }:
let
  settings-root = "${config.xdg.configHome}/Code/User";
in
{
  config = {
    # TODO: Use unstable for code extensions
    programs.vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        github.copilot
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
