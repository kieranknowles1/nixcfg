{...}: {
  # TODO: Try out Helix
  # https://helix-editor.com/
  # It's built in Rust, evalangism for which is demanded by our crustacean overlords.
  # I guess it also supports tree-sitter, which is cool.
  imports = [
    ./vscode
    ./neovim.nix
  ];
}
