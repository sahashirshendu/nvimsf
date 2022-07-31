local g   = vim.g
local o   = vim.o
local opt = vim.opt
local A   = vim.api

-- cmd('syntax on')
-- vim.api.nvim_command('filetype plugin indent on')

o.termguicolors = true
-- o.background = 'dark'

-- Do not save when switching buffers
-- o.hidden = true

-- Decrease update time
o.timeoutlen = 500
o.updatetime = 200

-- Number of screen lines to keep above and below the cursor
o.scrolloff = 3

-- Better editor UI
o.number = true
o.numberwidth = 2
o.relativenumber = false
o.signcolumn = 'yes'
o.cursorline = true

-- Better editing experience
o.expandtab = true
o.smarttab = true
o.cindent = true
o.autoindent = true
o.wrap = false
o.textwidth = 300
o.tabstop = 2
o.shiftwidth = 2
o.softtabstop = -1 -- If negative, shiftwidth value is used
o.list = true
o.whichwrap = "b,s,<,>,[,],h,l"
o.listchars = 'trail:·,nbsp:◇,tab:→ ,extends:▸,precedes:◂'
-- o.listchars = 'eol:¬,space:·,lead: ,trail:·,nbsp:◇,tab:→-,extends:▸,precedes:◂,multispace:···⬝,leadmultispace:│   ,'
-- o.formatoptions = 'qrn1'

-- Makes neovim and host OS clipboard play nicely with each other
o.clipboard = 'unnamedplus'

-- Case insensitive searching UNLESS /C or capital in search
o.ignorecase = true
o.smartcase = true

-- Undo and backup options
o.backup = false
o.writebackup = false
o.undofile = true
o.swapfile = false
-- o.backupdir = '/tmp/'
-- o.directory = '/tmp/'
-- o.undodir = '/tmp/'

-- Remember 50 items in commandline history
o.history = 50

-- Better buffer splitting
o.splitright = true
o.splitbelow = true

-- Preserve view while jumping
-- BUG This option causes an error!
-- o.jumpoptions = 'view'

-- BUG: this won't update the search count after pressing `n` or `N`
-- When running macros and regexes on a large file, lazy redraw tells neovim/vim not to draw the screen
-- o.lazyredraw = true

opt.mouse = "a"

-- Map <leader> to space
g.mapleader = ' '
g.maplocalleader = ' '

-- COLORSCHEMES
local ok, _ = pcall(vim.cmd, 'colorscheme base16-onedark')

-- Highlight the region on yank
A.nvim_create_autocmd('TextYankPost', {
    group = num_au,
    callback = function()
        vim.highlight.on_yank({ higroup = 'Visual', timeout = 120 })
    end,
})

-- KEYBINDINGS
local function map(m, k, v)
    vim.keymap.set(m, k, v, { silent = true })
end

-- Mimic shell movements
map('i', '<C-E>', '<ESC>A')
map('i', '<C-A>', '<ESC>I')

-- Buffers
map("n", "<TAB>", ":bnext<CR>")
map("n", "<S-TAB>", ":bprevious<CR>")


-- PLUGINS
local packer_bootstrap = false
local fn = vim.fn

local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({"git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path})
  vim.cmd[[packadd packer.nvim]]
end

vim.cmd("autocmd BufWritePost init.lua source <afile> | PackerSync")

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

  -- A better status line
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true },
    config = "require('lualine').setup()"
  }
  use {
    "akinsho/bufferline.nvim",
    config = "require('bufferline').setup()"
  }

  -- File management --
  use 'vifm/vifm.vim'
  use 'scrooloose/nerdtree'
  use 'tiagofumo/vim-nerdtree-syntax-highlight'
  use 'ryanoasis/vim-devicons'

  -- Tim Pope Plugins --
  use 'tpope/vim-surround'

  -- Syntax Highlighting and Colors --
  use 'PotatoesMaster/i3-vim-syntax'
  use 'kovetskiy/sxhkd-vim'
  use 'vim-python/python-syntax'
  use 'ap/vim-css-color'

  -- Junegunn Choi Plugins --
  use 'junegunn/goyo.vim'
  use 'junegunn/limelight.vim'
  use 'junegunn/vim-emoji'

  -- Colorschemes
  use 'RRethy/nvim-base16'

  -- Other stuff
  use 'frazrepo/vim-rainbow'

  if packer_bootstrap then
    require("packer").sync()
  end
end)
