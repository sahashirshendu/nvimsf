local packer_bootstrap = false
local fn = vim.fn
local api = vim.api

local conf = {
  profile = {
    enable = true,
    threshold = 0,
  },
  display = {
    open_fn = function()
      return require("packer.util").float({ border = "single" })
    end,
  },
}

local function packer_init()
  local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
  if fn.empty(fn.glob(install_path)) > 0 then
    packer_bootstrap = fn.system({"git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path})
    api.nvim_command('packadd packer.nvim')
  end

  api.nvim_create_autocmd("BufWritePost", { pattern = "init.lua", command = "source <afile> | PackerCompile" })
end

local function plugins(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'
  use 'nvim-lua/plenary.nvim'
  -- Colorschemes
  use 'marko-cerovac/material.nvim'
  -- Statusline
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true },
    config = function()
      require('lualine').setup({
        options = { theme = 'auto', icons_enabled = true, component_separators = "|", section_separators = { left = "", right = "" } },
        sections = { lualine_a = { "mode" }, lualine_b = { "filename" }, lualine_c = { "branch", "diff" }, lualine_x = { "fileformat", "encoding", "filetype" }, lualine_y = { }, lualine_z = { { "location", separator = { left = "", right = "" }, left_padding = 2 } } },
        extensions = { "nvim-tree" },
      })
    end
  }
  use {
    "akinsho/bufferline.nvim",
    config = function()
      require("bufferline").setup({
        options = { offsets = { { filetype = "NvimTree", text = "File Explorer", highlight = "Directory", text_align = "center" } } },
      })
    end
  }
  -- Treesitter
  use {
    "nvim-treesitter/nvim-treesitter", run = ":TSUpdate",
    requires = { "windwp/nvim-ts-autotag", "p00f/nvim-ts-rainbow" },
    config = function()
      require("nvim-treesitter.configs").setup {
        ensure_installed = {"bash", "lua", "python"}, highlight = { enable = true, disable = { "" }, additional_vim_regex_highlighting = true }, autopairs = { enable = true }, autotag = { enable = true }, rainbow = { enable = true, extended_mode = false, max_file_lines = nil } }
    end
  }
  use { "windwp/nvim-autopairs", config = function() require('nvim-autopairs').setup() end }
  -- NVimTree
  use { "kyazdani42/nvim-tree.lua", config = function() require('nvim-tree').setup() end }
  -- Git
  use { "lewis6991/gitsigns.nvim", config = function() require('gitsigns').setup() end }
  -- Comment
  use { "terrortylor/nvim-comment", config = function() require('nvim_comment').setup({ comment_empty = false }) end }
  -- WhichKey
  use {
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup { plugins = { marks = false, registers = false, presets = { operators = false, motions = false, text_objects = false, windows = false, nav = false, z = false, g = false } }, window = { border = "single", padding = { 1, 1, 1, 1 } }, layout = { align = "center" } }
      require("which-key").register({
        q = { ":q<CR>", "Quit" },
        w = { ":w<CR>", "Write" },
        e = { ":NvimTreeToggle<CR>", "Files" },
        f = { ":Format<CR>", "Format" },
        E = { ":e $MYVIMRC<CR>", "Config" },
        c = { ":CommentToggle<CR>", "Comment" },
        s = { ":PackerSync<CR>", "Update Plugins" },
        h = { ":s<CR>", "Horizontal Split" },
        v = { ":vs<CR>", "Vertical Split" },
        n = { ":enew <BAR> startinsert<CR>", "New File" },
      }, { prefix = "<leader>" })
      require("which-key").register({ c = { ":CommentToggle<CR>", "Comment" } }, { prefix = "<leader>", mode = "v" })
    end
  }
  -- Dashboard
  use {
    "glepnir/dashboard-nvim",
    config = function()
      local db = require("dashboard")
      db.custom_header = {
        [[ ██╗   ██╗ ]],
        [[ ██║   ██║ ]],
        [[ ╚██╗ ██╔╝ ]],
        [[  ╚████╔╝  ]],
        [[   ╚═══╝   ]],
      }
      db.custom_center = {
        { icon = "  ", desc = "New File                                ", action = "enew | startinsert", shortcut = " SPC n " },
        { icon = "  ", desc = "Config                                  ", action = "e $MYVIMRC", shortcut = " SPC E " },
        { icon = "  ", desc = "Sync                                    ", action = "PackerSync", shortcut = " SPC s " },
        { icon = "  ", desc = "Quit                                    ", action = "qa", shortcut = " SPC q " }
      }
      db.custom_footer = { "  " .. #vim.tbl_keys(packer_plugins) .. " plugins" }
    end
  }
  -- Impatient
  use "lewis6991/impatient.nvim"
  -- CMP
  use {
    "hrsh7th/nvim-cmp",
    requires = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lua",
      {"hrsh7th/cmp-buffer", after = "cmp-nvim-lua" },
      {"hrsh7th/cmp-path", after = "cmp-nvim-lua" },
      "hrsh7th/cmp-cmdline",
      { "hrsh7th/vim-vsnip", after = "nvim-cmp" },
      "rafamadriz/friendly-snippets",
      "hrsh7th/cmp-vsnip",
    },
    config = function ()
      require("conf.cmp")
    end
  }
  -- LSP
  use {
    "neovim/nvim-lspconfig",
    requires = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "jose-elias-alvarez/null-ls.nvim",
    },
    config = function ()
      require("conf.lsp")
    end
  }

  if packer_bootstrap then
    require("packer").sync()
  end
end

packer_init()
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

local present, impatient = pcall(require, "impatient")
if present then
  impatient.enable_profile()
end

packer.init(conf)
packer.startup(plugins)
