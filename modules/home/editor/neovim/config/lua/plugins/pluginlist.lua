return {
	-- 'gcc' to comment selection
	{
		"numToStr/Comment.nvim",
		opts = {},
	},
	-- Fancy bottom line
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({})
		end,
	},
	-- Automatically install language server binaries
	"williamboman/mason.nvim",
	"williamboman/mason-lspconfig.nvim",
	-- Provides configs for language servers
	"neovim/nvim-lspconfig",

	-- Code completion and snippets
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			-- 'L3MON4D3/LuaSnip',
			-- 'saadparwaiz1/cmp_luasnip',
			-- 'rafamadriz/friendly-snippets',
			"hrsh7th/cmp-nvim-lsp",

			-- Declarations for neovim
			"folke/neodev.nvim",
		},
	},

	-- Workspace search
	-- TODO: Use fzf-native version
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
	},

	-- TODO: Treesitter
	-- File tree
	{
		"nvim-neo-tree/neo-tree.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
			-- '3rd/image.nvim',
		},
	},
}
