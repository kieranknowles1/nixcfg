{
  ...
}:
{
  plugins = {
    bufferline.enable = true;
    lualine.enable = true;

    lsp = {
      enable = true;
      servers = {
        nil-ls.enable = true;
        pyright.enable = true;
      };
    };
  };
}
