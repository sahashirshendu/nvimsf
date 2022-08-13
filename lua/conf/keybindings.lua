vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local map = vim.keymap.set
local mapopts = { noremap = true, silent = true }

-- Mimic shell movements
map('i', '<C-E>', '<ESC>A', mapopts)
map('i', '<C-A>', '<ESC>I', mapopts)
-- Tav to switch Buffers
map("n", "<TAB>", ":bnext<CR>", mapopts)
map("n", "<S-TAB>", ":bprevious<CR>", mapopts)
-- Better Tabbing, Stay in indent mode
map("v", "<", "<gv", mapopts)
map("v", ">", ">gv", mapopts)
-- Ctrl+BS to delete previous word
map("!", "<C-BS>", "<C-w>", mapopts)
