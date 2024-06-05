{
  config,
  hostConfig,
  lib,
  pkgs-unstable,
  inputs,
  system,
  ...
}:
let
  settings-root = "${config.xdg.configHome}/Code/User";

  hostDevelopment = hostConfig.custom.development;

  extensionsRepo = inputs.vscode-extensions.extensions.${system};
in
{
  config = lib.mkIf hostDevelopment.enable {
    programs.vscode = {
      enable = true;

      # Use the latest version of VSCode from the unstable channel
      package = pkgs-unstable.vscode;

      extensions = with extensionsRepo.vscode-marketplace; [
        # Must-have extensions
        github.copilot
        github.copilot-chat
        gruntfuggly.todo-tree
        ms-vscode-remote.remote-ssh
        streetsidesoftware.code-spell-checker

        # Language support
        jnoortheen.nix-ide
        redhat.vscode-yaml
        tamasfe.even-better-toml
        thenuprojectcontributors.vscode-nushell-lang
        ms-python.python
        ms-python.vscode-pylance

        # Plain VSCode supports Markdown, but this extension
        # adds some nice features, namely table of contents
        yzhang.markdown-all-in-one
      ] ++ (lib.optionals hostDevelopment.modding.enable [
        joelday.papyrus-lang-vscode # Essential for Skyrim and Fallout 4 modding
      ]);
    };

    # TODO: Find a way that I can still edit and sync back
    # to the repo later
    home.file."${settings-root}/settings.json" = {
      source = ./settings.json;
    };
  };
}
