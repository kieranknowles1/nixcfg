local telescope = require("telescope.builtin")

local function on_attach(client, bufnr)
	local function bind(key, func)
		vim.keymap.set("n", key, func, { buffer = bufnr })
	end
	local function command(text, func)
		vim.api.nvim_buf_create_user_command(bufnr, text, func, {})
	end

	bind("<F2>", vim.lsp.buf.rename)
	bind("gd", vim.lsp.buf.definition)
	bind("gD", vim.lsp.buf.declaration)

	bind("gr", telescope.lsp_references)
	bind("<leader>s", telescope.lsp_document_symbols)
	bind("<leader>S", telescope.lsp_dynamic_workspace_symbols)

	-- Equivalent to hovering over with mouse
	bind("K", vim.lsp.buf.hover)

	-- TODO: Alt+Shift+F
	command("Format", function(_)
		vim.lsp.buf.format()
	end)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

local lsp = require("lspconfig")
local function mk_language_server(name, extra_config, before_hook)
	local result = {
		on_attach = on_attach,
		capabilities = capabilities,
	}

	for k, v in pairs(extra_config) do
		result[k] = v
	end

	return function()
		if before_hook then
			before_hook()
		end
		lsp[name].setup(result)
	end
end

-- TODO: Pin lsp versions
-- TODO: Auto install with Nix?
require("mason").setup()
require("mason-lspconfig").setup_handlers({
	-- Default setup for all language servers
	function(server_name)
		mk_language_server(server_name, {})()
	end,
	["lua_ls"] = mk_language_server("lua_ls", {}, function()
		require("neodev").setup()
	end),
})
