{
  config,
  lib,
  ...
}: {
  options.custom.editor = let
    inherit (lib) mkOption mkEnableOption types;
  in {
    enable = mkEnableOption "editor management";
    default = mkOption {
      type = types.enum [
        "vscode"
        "zed"
      ];

      description = ''
        The default editor to use.
      '';
    };

    textMimeTypes = mkOption {
      type = types.listOf types.str;

      description = ''
        A list of MIME types that are considered to be plaintext, and should be opened in the default editor.
      '';

      # Taken from nvim.desktop
      default = [
        "application/x-shellscript"
        "application/x-zerosize"
        "text/english"
        "text/plain"
        "text/x-c"
        "text/x-c++"
        "text/x-c++hdr"
        "text/x-c++src"
        "text/x-chdr"
        "text/x-csrc"
        "text/x-java"
        "text/x-makefile"
        "text/x-moc"
        "text/x-pascal"
        "text/x-tcl"
        "text/x-tex"
      ];
    };

    defaultCommand = mkOption {
      type = types.str;
      description = ''
        The command to run the default editor.
      '';
      readOnly = true;
    };
  };

  # LOOK: Try out Helix
  # https://helix-editor.com/
  # It's built in Rust, evalangism for which is demanded by our crustacean overlords.
  # I guess it also supports tree-sitter, which is cool.
  imports = [
    ./vscode
    ./zed
  ];

  config = let
    cfg = config.custom.editor;
    # The config of the default editor
    # All editors should have at least the following options:
    # - `enable`
    # - `desktopFile`
    defaultConfig = cfg.${cfg.default};
  in
    lib.mkIf cfg.enable {
      # Make sure our default editor is installed
      assertions = lib.singleton {
        assertion = defaultConfig.enable;
        message = "The default editor is set to ${cfg.default}, but it is not enabled.";
      };

      custom = {
        editor.defaultCommand = defaultConfig.command;
        # Like $EDITOR, but for GUIs
        extraEnv.GUIEDITOR = cfg.defaultCommand;
        aliases.e = {
          exec = "${cfg.defaultCommand} .";
          mnemonic = "[e]ditor";
        };

        # Assign the default GUI editor to handle text files
        mime.definition = lib.attrsets.genAttrs cfg.textMimeTypes (_type: {
          defaultApp = defaultConfig.desktopFile;
        });
      };
    };
}
