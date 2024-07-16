# Package to build our nixvim environment
# We use a package rather than nix module to allow for rapid iteration,
# as we only need to rebuild the package rather than the entire system
{
  pkgs,
  inputs,
}: let
  # List of languages to enable
  # Format: server = "language-server"; tsgrammar = tree-sitter-grammar;
  languages = with pkgs.vimPlugins.nvim-treesitter-parsers; [
    {
      server = "nil-ls";
      tsgrammar = nix;
    }
  ];
in
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
        treesitter = {
          enable = true;
          grammarPackages = builtins.map (language: language.tsgrammar) languages;
        };
        lualine.enable = true;

        # Bracket pair color/highlight
        rainbow-delimiters.enable = true;

        # File browser
        oil.enable = true;

        # Show untracked changes
        gitsigns.enable = true;

        # Search
        telescope = {
          enable = true;

          keymaps = {
            "<C-f>" = "current_buffer_fuzzy_find";
            # TODO: Search for all files in workspace
          };
        };

        # Language servers
        lsp = {
          enable = true;
          servers = builtins.listToAttrs (builtins.map (language: {
              name = language.server;
              value = {enable = true;};
            })
            languages);
        };

        # Snippets (not specific to Lua)
        luasnip.enable = true;
        friendly-snippets.enable = true;

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

      # TODO: Remove this once the plugins are properly configured
      extraConfigLua = builtins.concatStringsSep "\n" (builtins.map (file: builtins.readFile file) [
        ./config/lua/options.lua
        ./config/after/plugin/cmp.lua
        ./config/after/plugin/lsp.lua
        ./config/after/plugin/telescope.lua
        ./config/after/plugin/treesitter.lua
      ]);
    };
  }
