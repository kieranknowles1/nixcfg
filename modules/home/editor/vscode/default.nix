{
  config,
  hostConfig,
  lib,
  pkgs,
  ...
}: let
  userSettingsDir = "${config.xdg.configHome}/Code/User";
in {
  options.custom.editor.vscode = {
    enable = lib.mkEnableOption "VS Code";
  };

  config = lib.mkIf config.custom.editor.vscode.enable {
    # Rebuild will fail if any assertion is false. VSCode requires a desktop environment, so isn't useful on servers.
    # If code isn't enabled, the assertion will never be checked due to the mkIf.
    assertions = [
      {
        assertion = hostConfig.custom.deviceType != "server";
        message = "VS Code is not supported on servers. Use remote development instead.";
      }
    ];

    programs.vscode = {
      enable = true;

      extensions = with pkgs.vscode-marketplace; [
        # Must-have extensions
        github.copilot
        github.copilot-chat
        gruntfuggly.todo-tree
        isotechnics.commentlinks
        streetsidesoftware.code-spell-checker

        # Plain VSCode supports Markdown, but this extension
        # adds some nice features, namely table of contents
        yzhang.markdown-all-in-one

        # Language support
        jnoortheen.nix-ide # Nix IDE
        redhat.vscode-yaml # We have some YAML files in the repo
        tamasfe.even-better-toml # Same for TOML
        thenuprojectcontributors.vscode-nushell-lang # Nushell config
        ms-python.python # Used for several scripts in the repo
        ms-python.vscode-pylance

        joelday.papyrus-lang-vscode # Essential for Skyrim and Fallout 4 modding

        # Godot
        geequlim.godot-tools
        mrorz.language-gettext # Used for translations
      ];
    };

    home.file."${userSettingsDir}/settings.json" = let
      raw = builtins.readFile ./settings.json;
      replaceOriginals = [
        "__nil__"
        "__terminal__"
      ];
      replacements = [
        (lib.getExe pkgs.nil)
        (lib.getExe config.custom.terminal.package)
      ];
    in {
      text = builtins.replaceStrings replaceOriginals replacements raw;
    };
    home.file."${userSettingsDir}/snippets" = {
      source = ./snippets;
      recursive = true;
    };
  };
}
