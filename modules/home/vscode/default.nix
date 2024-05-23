{ config, pkgs, ... }:
let
  settings-root = "${config.xdg.configHome}/VSCodium/User";
in
{
  config = {
    # TODO: Use unstable for code extensions
    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;
      extensions = with pkgs.vscode-extensions; [
        gruntfuggly.todo-tree
        jnoortheen.nix-ide
      ];
    };

    # TODO: Find a way that I can still edit and sync back
    # to the repo later
    home.file."${settings-root}/settings.json" = {
      source = ./settings.json;
    };
  };
}