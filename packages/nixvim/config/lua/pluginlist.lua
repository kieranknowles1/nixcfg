return {
	-- Color scheme
	{
		"ellisonleao/gruvbox.nvim",
		priority = 1000,
		config = function() vim.cmd("colorscheme gruvbox") end,
	},
	-- "gcc" to comment line, "gbc" to comment block. Repeat command to uncomment
  {
		"numToStr/Comment.nvim",
		opts = {

		},
	},
	-- Status line
	{
	  "nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			theme = 'gruvbox_dark',
		},
	},
	-- Language server
	"williamboman/mason.nvim",
	"williamboman/mason-lspconfig.nvim",
	"neovim/nvim-lspconfig",
	-- Code completions
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			-- Add code snippet support
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"rafamadriz/friendly-snippets",
			-- nvim-cmp only provides the menu, so we also need to include a completion engine
			"hrsh7th/cmp-nvim-lsp",
		}
	},

	-- nvim config declarations
	'folke/neodev.nvim',

	-- Fancy search
	{
  	'nvim-telescope/telescope.nvim',
		-- FIXME: This doesn't work on NixOS
		dependencies = {
			{
			-- Native implementation that is faster. Needs gcc/clang to build
   		'nvim-telescope/telescope-fzf-native.nvim',
				build = 'make',
				config = function()
					require("telescope").load_extension("fzf")
				end,
			},
  	},
	},
	-- Improved code highlighting
	{
		'nvim-treesitter/nvim-treesitter',
		build = ':TSUpdate',
	},
}
