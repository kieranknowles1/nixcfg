-- Config for language servers

-- Function to be called after the lsp has started
local on_attach = function(client, buffer_number)
    -- Key bindings
    local mkMap = function(keys, func)
        -- 'n' to run in normal mode
        vim.keymap.set('n', keys, func, { buffer = buffer_number})
    end

    mkMap('<F2>', vim.lsp.buf.rename)
    mkMap('<leader>a', vim.lsp.buf.code_action)

    mkMap('gd', vim.lsp.buf.definition)
    mkMap('gD', vim.lsp.buf.declaration)
    mkMap('gI', vim.lsp.buf.implementation)
    mkMap('<leader>t', vim.lsp.buf.type_definition)

    local telescope = require('telescope.builtin')
    mkMap('gr', telescope.lsp_references)
    mkMap('<leader>s', telescope.lsp_document_symbols)
    mkMap('<leader>S', telescope.lsp_dynamic_workspace_symbols)

    -- Show hover info
    mkMap('K', vim.lsp.buf.hover)

    vim.api.nvim_buf_create_user_command(buffer_number, 'Format', function(_)
        vim.lsp.buf.format()
    end, {})
end

-- Configure language servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
local lspconfig = require('lspconfig')

lspconfig.lua_ls.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    Lua = {
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
    },
}

-- -- Install language servers as needed
-- Nixvim is handling this now
-- require("mason").setup()
-- require("mason-lspconfig").setup_handlers({
--     function(server_name)
--         -- Default handler for anything not explicitly configured
--         lspconfig[server_name].setup {
--             on_attach = on_attach,
--             capabilities = capabilities
--         }
--     end,
--     ["lua_ls"] = function()
--         require('neodev').setup()
--         lspconfig.lua_ls.setup {
--             on_attach = on_attach,
--             capabilities = capabilities,
--             Lua = {
--                 workspace = { checkThirdParty = false },
--                 telemetry = { enabled = false },
--             },
--         }
--     end,
-- })
