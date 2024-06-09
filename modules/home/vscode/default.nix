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
  settingsFile = "${config.xdg.configHome}/Code/User/settings.json";

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
        streetsidesoftware.code-spell-checker

        # Language support
        # TODO: Move all of these to an option for "development of this repo"
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
      ]) ++ (lib.optionals hostDevelopment.remote.enable [
        ms-vscode-remote.remote-ssh
      ]);
    };

    home.file."${settingsFile}" = {
      source = ./settings.json;
    };

    custom.edit-config.program.code = {
      system-path = settingsFile;
      repo-path = "modules/home/vscode/settings.json";
    };
  };
}
