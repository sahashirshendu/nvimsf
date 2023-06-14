-- OPTIONS
local g = vim.g
local o = vim.opt
local api = vim.api
local map = vim.keymap.set

o.termguicolors = true
-- o.background = 'dark'
-- o.hidden = true
o.timeoutlen = 200
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
o.softtabstop = -1
o.showmode = false
o.whichwrap = "b,s,<,>,[,],h,l"
o.pumheight = 10
o.pumblend = 10
o.clipboard = "unnamed,unnamedplus"
o.ignorecase = true
o.smartcase = true
o.backup = false
o.writebackup = false
o.undofile = false
o.swapfile = false
o.history = 100
o.splitright = true
o.splitbelow = true
o.mouse = "a"

-- Map <leader> to space
g.mapleader = ' '
g.maplocalleader = ' '

-- KEYBINDINGS
-- Shell movements
map('i', '<C-E>', '<ESC>A', {noremap = true, silent = true})
map('i', '<C-A>', '<ESC>I', {noremap = true, silent = true})
-- Tab over buffers
map("n", "<TAB>", ":bnext<CR>", {noremap = true, silent = true})
map("n", "<S-TAB>", ":bprevious<CR>", {noremap = true, silent = true})
-- Stay in indent mode
map("v", "<", "<gv", {noremap = true, silent = true})
map("v", ">", ">gv", {noremap = true, silent = true})
-- Ctrl+BS deletes previous word
map("!", "<C-BS>", "<C-w>", {noremap = true, silent = true})
map("!", "<C-h>", "<C-w>", {noremap = true, silent = true})

-- Snippets
local function snip_setup()
  local snip_status_ok, luasnip = pcall(require, "luasnip")
  if not snip_status_ok then
    return
  end

  local snip_folder = vim.fn.stdpath("config") .. "/snippets/"
  api.nvim_create_user_command("LuaSnipEdit", "lua require('luasnip.loaders').edit_snippet_files()", {})

  luasnip.config.set_config({
    history = true,
    ext_base_prio = 200,
    ext_prio_increase = 1,
    updateevents = "TextChanged,TextChangedI",
    enable_autosnippets = true,
    store_selection_keys = "<C-q>",
  })

  -- luasnip.filetype_extend("all", { "_" })

  -- Load Snippets
  require("luasnip.loaders.from_vscode").lazy_load()
  -- require("luasnip.loaders.from_vscode").lazy_load({ paths = snip_folder })
  require("luasnip.loaders.from_snipmate").lazy_load({ paths = snip_folder })
  -- require("luasnip.loaders.from_lua").lazy_load({ paths = snip_folder })
end

-- LSP
local function lsp_setup()
  -- LSP servers --
  local servers = {
    fortls = {},
    pyright = {analysis = {typeCheckingMode = "off"}},
    lua_ls = {
      settings = {
        Lua = {
          runtime = {version = "LuaJIT"},
          workspace = {library = vim.api.nvim_get_runtime_file("", true), checkThirdParty = false},
          completion = {callSnippet = "Replace"},
          telemetry = {enable = false},
          hint = {enable = true},
        },
      },
    },
  }

  local function lsp_handlers()
    -- Diagnostic Signs
    local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    -- LSP handlers configuration
    local config = {
      float = { focusable = true, style = "minimal", border = "single", },
      diagnostic = {
        -- virtual_text = false,
        signs = { active = signs, },
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = { focusable = true, style = "minimal", border = "single", source = "always", header = "", prefix = "", },
        -- virtual_lines = true,
      },
    }

    vim.diagnostic.config(config.diagnostic)
    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, config.float)
    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, config.float)
    vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
      underline = true,
      virtual_text = { spacing = 5, severity_limit = "Warning", },
      update_in_insert = true,
    })
  end

  local function on_attach(client, bufnr)
    -- Disable Formatting for tsserver, sumneko-lua
    -- if client.name == "tsserver" or client.name == "lua_ls" then
    --   client.server_capabilities.document_formatting = false
    -- end
  end

  -- LSP setup --
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true

  lsp_handlers()

  local opts = {
    on_attach = on_attach,
    capabilities = capabilities,
    flags = { debounce_text_changes = 150 },
  }

  local msls_status_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
  if not msls_status_ok then
    return
  end

  mason_lspconfig.setup({
    ensure_installed = vim.tbl_keys(servers),
    automatic_installation = false,
  })

  -- Set up LSP servers
  local lspconfig = require("lspconfig")
  local lspwin = require("lspconfig.ui.windows")
  lspwin.default_options.border = "single"
  for server_name, _ in pairs(servers) do
    local options = vim.tbl_deep_extend("force", opts, servers[server_name] or {})
    lspconfig[server_name].setup(options)
  end
end

-- PLUGINS
local plugins = {
  'nvim-lua/plenary.nvim',
  -- Colorschemes
  {'ellisonleao/gruvbox.nvim', config = function() vim.cmd('colorscheme gruvbox') end},
  -- Statusline
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'kyazdani42/nvim-web-devicons', },
    opts = {
      options = { component_separators = "|", section_separators = { left = "", right = "" } },
      sections = { lualine_x = { "fileformat", "encoding", "filetype" }, lualine_y = { }, lualine_z = { { "location", separator = { left = "", right = "" }, left_padding = 2 } } },
    }
  },
  {"akinsho/bufferline.nvim", opts = {options = {always_show_bufferline = false, show_buffer_close_icons = false, offsets = {{filetype = "NvimTree", text = "Files"}}}}},
  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter", build = ":TSUpdate",
    dependencies = { "windwp/nvim-ts-autotag", "p00f/nvim-ts-rainbow" },
    config = function() require("nvim-treesitter.configs").setup {ensure_installed = {"bash", "lua", "python"}, highlight = {enable = true, disable = {""}}, autopairs = {enable = true}, rainbow = {enable = true}} end
  },
  {"windwp/nvim-autopairs", opts = {}},
  -- NVimTree
  {"kyazdani42/nvim-tree.lua", opts = {}},
  -- Git
  {"lewis6991/gitsigns.nvim", opts = {}},
  -- Comment
  {"terrortylor/nvim-comment", name = "nvim_comment", opts = {comment_empty = false}},
  -- WhichKey
  {
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup {plugins = {marks = false, registers = false, presets = {operators = false, motions = false, text_objects = false, windows = false, nav = false, z = false, g = false}}, window = {border = "single", padding = {1, 1, 1, 1}}, layout = {align = "center"}}
      require("which-key").register({
        q = {":q<CR>", "Quit"},
        w = {":w<CR>", "Write"},
        e = {":NvimTreeToggle<CR>", "Files"},
        f = {":Format<CR>", "Format"},
        E = {":e $MYVIMRC<CR>", "Config"},
        c = {":CommentToggle<CR>", "Comment"},
        s = {":Lazy sync<CR>", "Update Plugins"},
        h = {":s<CR>", "Horizontal Split"},
        v = {":vs<CR>", "Vertical Split"},
        n = {":enew <BAR> startinsert<CR>", "New File"},
      }, {prefix = "<leader>"})
      require("which-key").register({c = {":CommentToggle<CR>", "Comment"}}, {prefix = "<leader>", mode = "v"})
    end
  },
  -- Dashboard
  {
    "nvimdev/dashboard-nvim",
    config = function()
      require("dashboard").setup {
        theme = 'doom',
        config = {
          header = {
            [[]],
            [[]],
            [[ ██╗   ██╗ ]],
            [[ ██║   ██║ ]],
            [[ ╚██╗ ██╔╝ ]],
            [[  ╚████╔╝  ]],
            [[   ╚═══╝   ]],
            [[]],
            [[]],
          },
          center = {
            { icon = "  ", desc = "New File                                ", action = "enew | startinsert", key = " SPC n " },
            { icon = "  ", desc = "Config                                  ", action = "e $MYVIMRC", key = " SPC E " },
            { icon = "  ", desc = "Sync                                    ", action = "Lazy sync", key = " SPC s " },
            { icon = "  ", desc = "Quit                                    ", action = "qa", key = " SPC q " }
          },
          footer = { "  " .. #vim.tbl_keys(require("lazy").plugins()) .. " plugins" }
        }
      }
    end
  },
  -- CMP
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      {
        "L3MON4D3/LuaSnip",
        dependencies = { "saadparwaiz1/cmp_luasnip", "rafamadriz/friendly-snippets" },
        config = function() snip_setup() end
      },
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local has_words_before = function()
        local line, col = unpack(api.nvim_win_get_cursor(0))
        return col ~= 0 and api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end
      cmp.setup({
        completion = {completeopt = "menu,menuone,noselect,noinsert", keyword_length = 1},
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert {
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-y>"] = cmp.config.disable,
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm {behavior = cmp.ConfirmBehavior.Replace, select = true},
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, {"i", "s"}),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, {"i", "s"}),
        },
        sources = {
          {name = "nvim_lsp"},
          {name = "nvim_lua"},
          {name = "luasnip"},
          {name = "buffer"},
          {name = "path"},
        },
        window = {documentation = {border = "single"}},
      })
      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {{name = "buffer"}},
      })
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources{{name = "path"}, {name = "cmdline"}},
      })
    end
  },
  -- LSP
  {
    "neovim/nvim-lspconfig",
    enabled = false,
    dependencies = {
      {
        "williamboman/mason.nvim",
        build = ":MasonUpdate",
        opts = {ui = {border = "single"}, ensure_installed = {}},
      },
      "williamboman/mason-lspconfig.nvim",
      {
        "jose-elias-alvarez/null-ls.nvim",
        config = function()
          local nls = require("null-ls")
          local nlsfmt = nls.builtins.formatting
          api.nvim_create_user_command("Format", "lua vim.lsp.buf.format({async = true})", {}) -- Builtin Formatting of NVim LSP
          nls.setup {border = "single", debug = false, sources = {nlsfmt.fprettify, nlsfmt.black, nlsfmt.stylua}}
        end,
      },
    },
    config = function() lsp_setup() end
  },
}

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({"git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup(plugins, {ui = {border = "single"}})
