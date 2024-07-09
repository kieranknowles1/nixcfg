{
  pkgs,
  config,
  lib,
  ...
}: {
  # TODO: Maybe allow multiple editors to be installed at the same time
  # TODO: Configure all the language servers I use
  # - Rust
  # - Nix
  # - Python
  # - Yaml
  # - Nu
  # - Toml
  config = lib.mkIf (config.custom.editor == "neovim") {
    programs.neovim = {
      enable = true;

      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
    };

    # Don't manage anything with Nix for now
    # TODO: Manage configs/plugins with Nix?
    xdg.configFile."nvim" = {
      source = ./config;
      recursive = true;
    };


    custom.edit-config.programs.nvim = {
      system-path = "~/.config/nvim";
      repo-path = "modules/home/editor/neovim/config";
    };
  };
}
