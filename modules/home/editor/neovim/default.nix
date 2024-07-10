{
  pkgs,
  config,
  lib,
  ...
}: {
  options.custom.editor.neovim = {
    enable = lib.mkEnableOption "NeoVim";
  };

  # TODO: Configure all the language servers I use
  # - Rust
  # - Nix
  # - Python
  # - Yaml
  # - Nu
  # - Toml
  config = lib.mkIf config.custom.editor.neovim.enable {
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
