{
  vim = {
    lsp = {
      # Enable language servers for all languages
      enable = true;
    };

    languages = {
      # Enable treesitter for all languages
      enableTreesitter = true;

      nix.enable = true;
      rust.enable = true;
    };

    autocomplete.nvim-cmp = {
      enable = true;
    };
  };
}
