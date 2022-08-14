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
o.softtabstop = -1 -- If negative, shiftwidth value is used
o.showmode = false
o.whichwrap = "b,s,<,>,[,],h,l"
o.pumheight = 10
o.pumblend = 10
-- o.list = true
-- o.listchars = 'trail:·,nbsp:◇,tab:→ ,extends:▸,precedes:◂'
-- o.listchars = 'eol:¬,space:·,lead: ,trail:·,nbsp:◇,tab:→-,extends:▸,precedes:◂,multispace:···⬝,leadmultispace:│   ,'
-- o.formatoptions = 'qrn1'
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
-- o.lazyredraw = true
o.mouse = "a"

-- Map <leader> to space
g.mapleader = ' '
g.maplocalleader = ' '

-- COLORSCHEMES
local _, _ = pcall(api.nvim_command, 'colorscheme material')

-- KEYBINDINGS
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
map("!", "<C-h>", "<C-w>", mapopts)

-- CMP
g.completeopt = "menu,menuone,noselect,noinsert"

local function cmp_setup()
  local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
  end

  local feedkey = function(key, mode)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
  end

  local cmp_status_ok, cmp = pcall(require, "cmp")
  if not cmp_status_ok then
    return
  end

  cmp.setup({
    snippet = {
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert {
      ["<C-b>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<C-y>"] = cmp.config.disable,
      ["<C-e>"] = cmp.mapping.abort(),
      ["<CR>"] = cmp.mapping.confirm {
        behavior = cmp.ConfirmBehavior.Replace,
        select = true,
      },
      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif vim.fn["vsnip#available"](1) == 1 then
          feedkey("<Plug>(vsnip-expand-or-jump)", "")
        elseif has_words_before() then
          cmp.complete()
        else
          fallback()
        end
      end, { "i", "s" }),
      ["<S-Tab>"] = cmp.mapping(function()
        if cmp.visible() then
          cmp.select_prev_item()
        elseif vim.fn["vsnip#jumpable"](-1) == 1 then
          feedkey("<Plug>(vsnip-jump-prev)", "")
        end
      end, { "i", "s" }),
    },
    sources = {
      { name = "nvim_lsp" },
      { name = "nvim_lua" },
      { name = "vsnip" },
      { name = "buffer" },
      { name = "path" },
      { name = "treesitter" },
    },
    window = {
      documentation = { border = "single", },
    },
  })

  cmp.setup.cmdline("/", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = { { name = "buffer" } },
  })

  cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources{ { name = "path" }, { name = "cmdline" } },
  })
end

-- LSP
local function lsp_setup()
  -- Null-LS --
  local null_ls_status_ok, null_ls = pcall(require, "null-ls")
  if not null_ls_status_ok then
    return
  end

  local formatting = null_ls.builtins.formatting
  local diagnostics = null_ls.builtins.diagnostics

  api.nvim_create_user_command("Format", "lua vim.lsp.buf.formatting()", {}) -- Builtin Formatting of NVim LSP

  null_ls.setup({
    debug = false,
    sources = {
      formatting.prettier,
      formatting.black,
      formatting.fprettify,
      formatting.shfmt,
      formatting.clang_format,
      formatting.cmake_format,
      formatting.stylua,
    },
  })

  -- LSP servers --
  local servers = {
    bashls = {},
    cssls = {},
    emmet_ls = {},
    fortls = {},
    html = {},
    pyright = {
      analysis = {
        typeCheckingMode = "off",
      },
    },
    sumneko_lua = {
      settings = {
        Lua = {
          runtime = {
            version = "LuaJIT",
            path = vim.split(package.path, ";"),
          },
          diagnostics = {
            globals = { "vim", "describe", "it", "before_each", "after_each", "packer_plugins" },
            -- disable = { "lowercase-global", "undefined-global", "unused-local", "unused-vararg", "trailing-space" },
          },
          workspace = {
            library = {
              [vim.fn.expand("$VIMRUNTIME/lua")] = true,
              [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
              [vim.fn.stdpath("config") .. "/lua"] = true,
            },
            -- library = api.nvim_get_runtime_file("", true),
            maxPreload = 2000,
            preloadFileSize = 50000,
          },
          completion = { callSnippet = "Both" },
          telemetry = { enable = false },
          hint = {
            enable = true,
          },
        },
      },
    },
    texlab = {},
    tsserver = { disable_formatting = true },
    vimls = {},
  }

  -- LSP functions --
  local function keymaps(client, bufnr)
    local opts = { noremap = true, silent = true }
    map("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
    map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
    map("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
    map("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
    map("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
    map("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
    map("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
    map("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
    map("n", "<leader>f", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
    map("n", "[d", '<cmd>lua vim.diagnostic.goto_prev({ border = "rounded" })<CR>', opts)
    map("n", "gl", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
    map("n", "]d", '<cmd>lua vim.diagnostic.goto_next({ border = "rounded" })<CR>', opts)
    map("n", "<leader>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
  end

  local function highlighter(client, bufnr)
    if client.server_capabilities.documentHighlightProvider then
      local lsp_highlight_grp = api.nvim_create_augroup("LspDocumentHighlight", { clear = true })
      api.nvim_create_autocmd("CursorHold", {
        callback = function()
          vim.schedule(vim.lsp.buf.document_highlight)
        end,
        group = lsp_highlight_grp,
        buffer = bufnr,
      })
      api.nvim_create_autocmd("CursorMoved", {
        callback = function()
          vim.schedule(vim.lsp.buf.clear_references)
        end,
        group = lsp_highlight_grp,
        buffer = bufnr,
      })
    end
  end

  local function formatting(client, bufnr)
    if client.server_capabilities.documentFormattingProvider then
      local function format()
        local view = vim.fn.winsaveview()
        vim.lsp.buf.formatting({
          async = true,
          filter = function(attached_client)
            return attached_client.name ~= ""
          end,
        })
        vim.fn.winrestview(view)
        print("Buffer formatted")
      end

      local lsp_format_grp = api.nvim_create_augroup("LspFormat", { clear = true })
      api.nvim_create_autocmd("BufWritePre", {
        callback = function()
          vim.schedule(format)
        end,
        group = lsp_format_grp,
        buffer = bufnr,
      })
    end
  end

  local function lsp_handlers()
    -- Diagnostic Signs
    local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    -- LSP handlers configuration
    local config = {
      float = { focusable = true, style = "minimal", border = "rounded", },
      diagnostic = {
        -- virtual_text = false,
        -- virtual_text = { spacing = 4, prefix = "●" },
        virtual_text = { severity = vim.diagnostic.severity.ERROR },
        signs = { active = signs, },
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = { focusable = true, style = "minimal", border = "rounded", source = "always", header = "", prefix = "", },
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
    -- Enable completion triggered by <C-X><C-O>
    api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
    -- Use LSP as the handler for formatexpr.
    api.nvim_buf_set_option(0, "formatexpr", "v:lua.vim.lsp.formatexpr()")
    -- tagfunc
    if client.server_capabilities.definitionProvider then
      api.nvim_buf_set_option(bufnr, "tagfunc", "v:lua.vim.lsp.tagfunc")
    end
    -- Disable Formatting for tsserver, sumneko-lua
    if client.name == "tsserver" or client.name == "sumneko_lua" then
      client.resolved_capabilities.document_formatting = false
    end

    -- require("keymaps").setup(client, bufnr)
    -- require("highlighter").setup(client, bufnr)
    -- require("formatting").setup(client, bufnr)
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

  local ms_status_ok, mason = pcall(require, "mason")
  if not ms_status_ok then
    return
  end
  local msls_status_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
  if not msls_status_ok then
    return
  end

  mason.setup({
    ui = {
      border = "single",
      icons = {
        package_installed = "✓",
        package_pending = "➜",
        package_uninstalled = "✗",
      },
    },
  })

  mason_lspconfig.setup({
    ensure_installed = vim.tbl_keys(servers),
    automatic_installation = false,
  })

  -- Set up LSP servers
  local lspconfig = require("lspconfig")
  for server_name, _ in pairs(servers) do
    local options = vim.tbl_deep_extend("force", opts, servers[server_name] or {})

    lspconfig[server_name].setup(options)
  end
end

-- PLUGINS
local packer_bootstrap = false
local fn = vim.fn

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
    config = cmp_setup()
  }
  -- LSP
  use {
    "neovim/nvim-lspconfig",
    requires = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "jose-elias-alvarez/null-ls.nvim",
    },
    config = lsp_setup()
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