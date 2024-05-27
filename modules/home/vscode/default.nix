{ config, pkgs-unstable, ... }:
let
  settings-root = "${config.xdg.configHome}/Code/User";
in
{
  # TODO: Condition this based on host development option
  config = {
    programs.vscode = {
      enable = true;
      extensions = with pkgs-unstable.vscode-extensions; [
        # Must-have extensions
        github.copilot
        github.copilot-chat
        gruntfuggly.todo-tree
        ms-vscode-remote.remote-ssh

        # Language support
        jnoortheen.nix-ide
        redhat.vscode-yaml
        tamasfe.even-better-toml
        thenuprojectcontributors.vscode-nushell-lang

        # Plain VSCode supports Markdown, but this extension
        # adds some nice features, namely table of contents
        yzhang.markdown-all-in-one
      ];
    };

    # TODO: Find a way that I can still edit and sync back
    # to the repo later
    home.file."${settings-root}/settings.json" = {
      source = ./settings.json;
    };
  };
}
