{
  vim = {
    options.shiftwidth = 2;

    telescope = {
      enable = true;
    };

    binds.whichKey = {
      enable = true;
    };

    keymaps = [
      {
        key = "<leader>g";
        mode = "n";
        action = ":terminal lazygit<CR>i";
      }
    ];
  };
}
