{
  config,
  hostConfig,
  lib,
  pkgs,
  ...
}: {
  options.custom.editor.vscode = let
    inherit (lib) mkOption mkEnableOption types;
  in {
    enable = mkEnableOption "VS Code";
    desktopFile = mkOption {
      description = "Name of the .desktop file";
      default = "code.desktop";
      type = types.str;
      readOnly = true;
    };

    command = mkOption {
      description = "Command to run the editor";
      default = "code";
      type = types.str;
      readOnly = true;
    };
  };

  config = lib.mkIf config.custom.editor.vscode.enable {
    # Rebuild will fail if any assertion is false. VSCode requires a desktop environment, so isn't useful on servers.
    # If code isn't enabled, the assertion will never be checked due to the mkIf.
    assertions = lib.singleton {
      assertion = hostConfig.custom.features.desktop;
      message = "VS Code requires a desktop environment.";
    };

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

        # GLSL
        slevesque.shader
        dtoplak.vscode-glsllint

        # Godot
        geequlim.godot-tools
        mrorz.language-gettext # Used for translations
      ];
    };

    home.packages = with pkgs; [
      # Required by jnoortheen.nix-ide
      nil

      # Required by dtoplak.vscode-glsllint
      glslang
    ];

    custom.mutable.file = config.custom.mutable.provisionDir {
      baseRepoPath = "modules/home/editor/vscode";
      baseSystemPath = "${config.xdg.configHome}/Code/User";
      files = [
        "settings.json"
        "keybindings.json"
        "snippets/cmake.json"
        "snippets/cpp.json"
        "snippets/python.json"
      ];
    };
  };
}
