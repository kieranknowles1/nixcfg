# Package to build our nixvim environment
# We use a package rather than nix module to allow for rapid iteration,
# as we only need to rebuild the package rather than the entire system
{
  pkgs,
  inputs,
}:
inputs.nixvim.legacyPackages.${pkgs.system}.makeNixvimWithModule {
  module = {
    opts = {
      number = true;

      # Use two spaces for tabs
      shiftwidth = 2;

      # Insert spaces on new lines
      expandtab = true;
    };

    colorschemes.gruvbox.enable = true;

    plugins = {
      treesitter.enable = true;
      lualine.enable = true;

      # Bracket pair color/highlight
      rainbow-delimiters.enable = true;

      # File browser
      oil.enable = true;

      # Show untracked changes
      gitsigns.enable = true;

      # Language servers
      lsp = {
        enable = true;
        servers = {
          # Nix
          nil-ls.enable = true;
          # Lua
          lua-ls.enable = true;
        };
      };

      # Completions
      cmp = {
        enable = true;
        settings = {
          autoEnableSources = true;

          experimental = {
            ghost_text = true;
          };

          sources = [
            {name = "nvim_lsp";}
          ];
        };
      };
    };
  };
}
