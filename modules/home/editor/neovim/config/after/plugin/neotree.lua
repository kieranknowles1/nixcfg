-- TODO: Can this be done more cleanly
vim.api.nvim_create_user_command("Tree", function()
	vim.cmd("Neotree")
end, {})
vim.cmd("nnoremap <C-f> :Neotree<cr>")
