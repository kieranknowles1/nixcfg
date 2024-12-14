-- Substiture <leader> in keybindings with this
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Show line numbers
vim.o.number = true
-- Column for Git changes
vim.o.signcolumn = "yes"

-- Use spaces for tabs
vim.o.shiftwidth = 4
vim.o.expandtab = true

-- Allow using the mouse
vim.o.mouse = "a"

-- Nicer theme
vim.cmd("colorscheme retrobox")
