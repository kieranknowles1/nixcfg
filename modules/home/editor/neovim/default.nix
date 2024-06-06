{
  config,
  lib,
  pkgs,
  ...
}: {
  # TODO: Configure neovim
  config = lib.mkIf (config.custom.development.editor == "neovim") {
    programs.neovim = {
      enable = true;

      plugins = with pkgs.vimPlugins; [
        nvim-lspconfig
      ];
    };
  };
}
