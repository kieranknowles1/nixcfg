{
  config,
  lib,
  ...
}: {
  options.custom.editor = let
    defaultEditorOption = type:
      lib.mkOption {
        # Trying to access an unset option will throw an error,
        # so we need to use `null` to represent unset.
        type = with lib.types;
          nullOr (enum [
            "code"
            "nvim"
          ]);

        description = ''
          The default ${type} editor to use.
        '';

        default = null;
      };
  in {
    # TODO: This should set $EDITOR
    default = defaultEditorOption "cli";
    defaultGui = defaultEditorOption "gui";

    textMimeTypes = lib.mkOption {
      type = lib.types.listOf lib.types.str;

      description = ''
        A list of MIME types that are considered to be text files, and should be opened in a text editor.
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
  };

  # TODO: Try out Helix
  # https://helix-editor.com/
  # It's built in Rust, evalangism for which is demanded by our crustacean overlords.
  # I guess it also supports tree-sitter, which is cool.
  # TODO: Try Zed
  imports = [
    ./vscode
    ./neovim.nix
  ];

  config = let
    cfg = config.custom.editor;

    editorEnabled = command: let
      commandToOption = with cfg; {
        code = vscode.enable;
        nvim = neovim.enable;
      };
    in
      commandToOption.${command};

    toDesktopFile = name: let
      dict = {
        code = "code.desktop";
        nvim = "nvim.desktop";
      };
    in
      dict.${name};

    defaultEditor = cfg.default;

    defaultGui =
      if cfg.defaultGui != null
      then cfg.defaultGui
      else defaultEditor;

    checkEditorEnabled = type: editor:
      lib.optional (editor != null) {
        assertion = editorEnabled editor;
        message = "The default ${type} editor is set to ${editor}, but it is not enabled.";
      };
  in
    {
      # Make sure our default editor is installed
      assertions =
        (checkEditorEnabled "CLI" defaultEditor)
        ++ (checkEditorEnabled "GUI" defaultGui);
    }
    // (lib.mkIf (defaultGui != null)) {
      # Assign the default GUI editor to handle text files
      custom.mime.definition = lib.attrsets.genAttrs cfg.textMimeTypes (_type: {
        defaultApp = toDesktopFile defaultGui;
      });
    };
}
