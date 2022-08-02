-- OPTIONS
local g = vim.g
local o = vim.opt

o.termguicolors = true
-- o.background = 'dark'
-- o.hidden = true
o.timeoutlen = 500
o.updatetime = 200
o.scrolloff = 3 -- Number of screen lines to keep above and below the cursor
o.number = true -- Line Number
o.relativenumber = false -- Relative line number
o.signcolumn = 'yes'
o.cursorline = true
o.expandtab = true
o.smarttab = true
o.cindent = true
o.autoindent = true
o.wrap = false
o.textwidth = 300
o.tabstop = 2
o.shiftwidth = 2
o.softtabstop = -1 -- If negative, shiftwidth value is used
o.showmode = false
o.whichwrap = "b,s,<,>,[,],h,l"
-- o.list = true
-- o.listchars = 'trail:·,nbsp:◇,tab:→ ,extends:▸,precedes:◂'
-- o.listchars = 'eol:¬,space:·,lead: ,trail:·,nbsp:◇,tab:→-,extends:▸,precedes:◂,multispace:···⬝,leadmultispace:│   ,'
-- o.formatoptions = 'qrn1'
o.clipboard = 'unnamedplus' -- Make the clipboard operations doable
o.ignorecase = true
o.smartcase = true
o.backup = false
o.writebackup = false
o.undofile = false
o.swapfile = false
o.history = 100
o.splitright = true
o.splitbelow = true
-- o.lazyredraw = true
o.mouse = "a"

-- Map <leader> to space
g.mapleader = ' '
g.maplocalleader = ' '

-- COLORSCHEMES
local ok, _ = pcall(vim.cmd, 'colorscheme base16-onedark')

-- KEYBINDINGS
local function map(m, k, v)
    vim.keymap.set(m, k, v, { silent = true })
end

-- Mimic shell movements
map('i', '<C-E>', '<ESC>A')
map('i', '<C-A>', '<ESC>I')
-- Tav to switch Buffers
map("n", "<TAB>", ":bnext<CR>")
map("n", "<S-TAB>", ":bprevious<CR>")
-- Better Tabbing, Stay in indent mode
map("v", "<", "<gv")
map("v", ">", ">gv")
-- Leader
map('n', '<leader>w', ':w<CR>')
map('n', '<leader>q', ':q<CR>')
map('n', '<leader>s', ':PackerSync<CR>')
map('n', '<leader>k', ':CommentToggle<CR>')
map('v', '<leader>k', ':CommentToggle<CR>')
map('n', '<leader>e', ':NvimTreeToggle<CR>')

-- PLUGINS
local packer_bootstrap = false
local fn = vim.fn

local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({"git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path})
  vim.cmd[[packadd packer.nvim]]
end

vim.cmd("autocmd BufWritePost init.lua source <afile> | PackerCompile")

local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

packer.init({
  display = {
    open_fn = function()
      return require("packer.util").float({ border = "single" })
    end,
  },
})

return packer.startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'
  -- Colorschemes
  use 'RRethy/nvim-base16'
  -- Statusline
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true },
    config = function()
      require('lualine').setup({
        options = { theme = 'auto', icons_enabled = true, component_separators = "|", section_separators = { left = "", right = "" } },
        sections = { lualine_a = { "mode" }, lualine_b = { "filename" }, lualine_c = { "branch" }, lualine_x = { "fileformat", "encoding", "filetype" }, lualine_y = { }, lualine_z = { { "location", separator = { left = "", right = "" }, left_padding = 2 } } },
        extensions = { "nvim-tree" },
      })
    end
  }
  use { "akinsho/bufferline.nvim", config = function() require('bufferline').setup() end }
  -- Treesitter
  use {
    "nvim-treesitter/nvim-treesitter", run = ":TSUpdate",
    requires = { "windwp/nvim-ts-autotag", "p00f/nvim-ts-rainbow" },
    config = function()
      require("nvim-treesitter.configs").setup {
        highlight = { enable = true, disable = { "" }, additional_vim_regex_highlighting = true }, autopairs = { enable = true }, autotag = { enable = true }, rainbow = { enable = true, extended_mode = false, max_file_lines = nil } }
    end
  }
  use { "windwp/nvim-autopairs", config = function() require('nvim-autopairs').setup() end }
  -- NVimTree
  use { "kyazdani42/nvim-tree.lua", config = function() require('nvim-tree').setup() end }
  -- Git
  use { "lewis6991/gitsigns.nvim", config = function() require('gitsigns').setup() end }
  -- Comment
  use { "terrortylor/nvim-comment", config = function() require('nvim_comment').setup({ comment_empty = false }) end }

  if packer_bootstrap then
    require("packer").sync()
  end
end)
