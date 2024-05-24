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

        # Language support
        jnoortheen.nix-ide
        redhat.vscode-yaml
        tamasfe.even-better-toml
        thenuprojectcontributors.vscode-nushell-lang
      ];
    };

    # TODO: Find a way that I can still edit and sync back
    # to the repo later
    home.file."${settings-root}/settings.json" = {
      source = ./settings.json;
    };
  };
}
