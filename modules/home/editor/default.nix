{
  config,
  lib,
  ...
}: {
  options.custom.editor = {
    # TODO: This should set $EDITOR
    default = lib.mkOption {
      # Trying to access an unset option will throw an error,
      # so we need to use `null` to represent unset.
      type = with lib.types;
        nullOr (enum [
          "code"
          "nvim"
        ]);

      default = null;

      description = ''
        The default editor to use.
        Note that the value of this is the command to run the editor.
      '';
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
    editorEnabled = command: let
      commandToOption = with config.custom.editor; {
        code = vscode.enable;
        nvim = neovim.enable;
      };
    in
      commandToOption.${command};

    defaultEditor = config.custom.editor.default;
  in {
    # Make sure our default editor is installed
    assertions =
      lib.optional (defaultEditor != null)
      {
        assertion = editorEnabled defaultEditor;
        message = "The default editor is set to ${defaultEditor}, but it is not enabled.";
      };
  };
}
