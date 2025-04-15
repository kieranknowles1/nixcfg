-- local cmp = require('cmp')
-- local luasnip = require('luasnip')

-- -- Load snippets
-- require('luasnip.loaders.from_vscode').lazy_load()
-- luasnip.config.setup {}

-- local confirm = cmp.mapping.confirm({
--     behaviour = cmp.ConfirmBehavior.replace,
--     select = true,
-- })

-- cmp.setup {
--     snippet = {
--         expand = function(args)
--             luasnip.lsp_expand(args.body)
--         end,
--     },
--     mapping = cmp.mapping.preset.insert {
--         ['<C-n>'] = cmp.mapping.select_next_item(),
--         ['<C-Space>'] = cmp.mapping.complete(),
--         ['<CR>'] = confirm,
--         ['<Tab>'] = confirm,
--     },
--     sources = {
--         { name = 'nvim_lsp' },
--         { name = 'luasnip' },
--     },
-- }
