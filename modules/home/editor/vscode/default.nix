{
  config,
  hostConfig,
  lib,
  pkgs-unstable,
  inputs,
  ...
}: let
  userSettingsDir = "${config.xdg.configHome}/Code/User";

  hostDevelopment = hostConfig.custom.development;

  extensionsRepo = inputs.vscode-extensions.extensions.${hostConfig.nixpkgs.hostPlatform.system};
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

      # Use the latest version of VSCode from the unstable channel
      package = pkgs-unstable.vscode;

      extensions = with extensionsRepo.vscode-marketplace;
        [
          # Must-have extensions
          github.copilot
          github.copilot-chat
          gruntfuggly.todo-tree
          isotechnics.commentlinks
          streetsidesoftware.code-spell-checker

          # Plain VSCode supports Markdown, but this extension
          # adds some nice features, namely table of contents
          yzhang.markdown-all-in-one
        ]
        ++ (lib.optionals hostDevelopment.meta.enable [
          jnoortheen.nix-ide # Nix IDE
          redhat.vscode-yaml # We have some YAML files in the repo
          tamasfe.even-better-toml # Same for TOML
          thenuprojectcontributors.vscode-nushell-lang # Nushell config
          ms-python.python # Used for several scripts in the repo
          ms-python.vscode-pylance
        ])
        ++ (lib.optionals hostDevelopment.modding.enable [
          joelday.papyrus-lang-vscode # Essential for Skyrim and Fallout 4 modding
        ])
        ++ (lib.optionals hostDevelopment.remote.enable [
          ms-vscode-remote.remote-ssh
        ]);
    };

    home.file."${userSettingsDir}/settings.json" = {
      source = ./settings.json;
    };
    home.file."${userSettingsDir}/snippets" = {
      source = ./snippets;
      recursive = true;
    };

    custom.edit-config.programs.code = {
      system-path = userSettingsDir;
      repo-path = "modules/home/editor/vscode/";
      ignore-paths = [
        "History"
        "globalStorage"
        "workspaceStorage"
      ];
    };
  };
}
