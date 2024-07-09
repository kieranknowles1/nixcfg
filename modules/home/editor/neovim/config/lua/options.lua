-- Set tab width
local TAB_WIDTH = 2

vim.o.tabstop = TAB_WIDTH
vim.o.shiftwidth = TAB_WIDTH

-- Show line numbers
vim.o.number = true

-- Have a column for any errors/warnings
vim.o.signcolumn = 'yes'

-- Replace <leader> in any bindings with space
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

