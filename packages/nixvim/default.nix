# Package to build our nixvim environment
# We use a package rather than nix module to allow for rapid iteration,
# as we only need to rebuild the package rather than the entire system
{
  pkgs,
  inputs,
  # Enable optimization to try and reduce startup time
  optimize ? true,
}: let
  # TODO: Configure all the language servers I use
  # - Nu
  # - Python
  # - Toml
  # - Yaml
  # List of languages to enable
  # Format: server = "language-server"; tsgrammar = tree-sitter-grammar; serverConfig = {options = "here"};
  # See https://nix-community.github.io/nixvim/plugins/lsp/index.html for a list of available servers
  # See https://search.nixos.org/packages?&type=packages&query=vimPlugins.nvim-treesitter-parsers for a list of available grammars
  languages = with pkgs.vimPlugins.nvim-treesitter-parsers; [
    {
      server = "lua-ls";
      tsgrammar = lua;
    }
    {
      server = "nil-ls";
      tsgrammar = nix;
    }
    {
      server = "rust-analyzer";
      tsgrammar = rust;

      # rust-analyzer complains if it can't find rustc or cargo on the path
      serverConfig = {
        installCargo = true;
        installRustc = true;
      };
    }
  ];
in
  inputs.nixvim.legacyPackages.${pkgs.system}.makeNixvimWithModule {
    module = {
      performance = {
        byteCompileLua = {
          enable = optimize;
          configs = true;
          initLua = true;
          nvimRuntime = true;
          plugins = true;
        };
      };
      opts = {
        # Show line numbers
        number = true;

        # Use two spaces for tabs
        shiftwidth = 2;

        # Insert spaces when pressing <Tab>
        # TODO: Way to find and replace all tabs with spaces
        expandtab = true;

        # Add a column to show errors/warnings
        # gitsigns uses this to show untracked changes, and if we don't enable it
        # the contents shift when making our first change
        signcolumn = "yes";
      };

      colorschemes.gruvbox.enable = true;

      plugins = {
        treesitter = {
          # TODO: How do I get inline code highlighting?
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
              value = {enable = true;} // (language.serverConfig or {});
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

            mapping = let
              # TODO: Mappings:
              # - Arrows/jk to go up/down list
              # - <CR>/<Tab> to confirm
              # - <Ctrl_Space> to show completion menu
              confirm =
                /*
                lua
                */
                ''
                  cmp.mapping.confirm({
                    behavior = cmp.ConfirmBehavior.replace,
                    select = true,
                  })
                '';
            in {
              "<CR>" = confirm;
              "<Tab>" = confirm;
            };
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
