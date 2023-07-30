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
o.whichwrap = 'b,s,<,>,[,],h,l'
o.pumheight = 10
o.pumblend = 10
o.clipboard = 'unnamed,unnamedplus'
o.ignorecase = true
o.smartcase = true
o.backup = false
o.writebackup = false
o.undofile = false
o.swapfile = false
o.history = 100
o.splitright = true
o.splitbelow = true
o.mouse = 'a'
o.ruler = false

-- AUTOCOMMANDS
api.nvim_create_autocmd('TextYankPost', {pattern = '*', command = 'lua vim.highlight.on_yank()'}) -- copy on yank
api.nvim_create_autocmd({'FocusGained', 'TermClose', 'TermLeave'}, {command = 'checktime'}) -- reload changed file
api.nvim_create_autocmd({'BufWinEnter', 'BufEnter'}, {command = 'set formatoptions-=cro'}) -- don't auto comment new line
api.nvim_create_autocmd('TermOpen', {pattern = '*', command = 'startinsert'}) -- open terminal in insert mode
api.nvim_create_autocmd('BufReadPost', {command = [[if line("'\"") > 1 && line("'\"") <= line("$") | execute "normal! g`\"" | endif]]}) -- restore cursor position
api.nvim_create_autocmd('FileType', {pattern = {'checkhealth', 'help', 'lspinfo', 'man', 'qf', 'startuptime'}, command = 'nnoremap <buffer><silent> q :bdelete!<CR>'}) -- windows to close with "q"

-- KEYBINDINGS
g.mapleader = ','

-- Shell movements
map('i', '<C-E>', '<ESC>A')
map('i', '<C-A>', '<ESC>I')
-- Tab over buffers
map('n', '<TAB>', ':bnext<CR>')
map('n', '<S-TAB>', ':bprevious<CR>')
-- Stay in indent mode
map('v', '<', '<gv')
map('v', '>', '>gv')
-- Ctrl+BS deletes previous word
map('!', '<C-BS>', '<C-w>')
map('!', '<C-h>', '<C-w>')
-- Others
map('n', '<leader>q', ':q<CR>', {desc = 'Quit'})
map('n', '<leader>w', ':w<CR>', {desc = 'Write'})
map('n', '<leader>E', ':e $MYVIMRC<CR>', {desc = 'Config'})
map('n', '<leader>e', ':NvimTreeToggle<CR>', {desc = 'Files'})
map('n', '<leader>s', ':Lazy sync<CR>', {desc = 'Update Plugins'})
map('n', '<leader>c', ':CommentToggle<CR>', {desc = 'Comment'})
map('v', '<leader>c', ':CommentToggle<CR>', {desc = 'Comment'})
map('n', '<leader>n', ':enew <BAR> startinsert<CR>', {desc = 'New File'})

-- LSP
local function lsp_setup()
  -- LSP servers --
  local servers = {
    fortls = {},
    pyright = {analysis = {typeCheckingMode = 'off'}},
    lua_ls = {
      settings = {
        Lua = {
          runtime = {version = 'LuaJIT'},
          workspace = {library = vim.api.nvim_get_runtime_file('', true), checkThirdParty = false},
          telemetry = {enable = false},
        },
      },
    },
  }

  local function lsp_handlers()
    -- Diagnostic Signs
    local signs = {Error = ' ', Warn = ' ', Hint = ' ', Info = ' '}
    for type, icon in pairs(signs) do
      local hl = 'DiagnosticSign' .. type
      vim.fn.sign_define(hl, {text = icon, texthl = hl, numhl = ''})
    end

    -- LSP handlers configuration
    local config = {
      float = {focusable = true, style = 'minimal', border = 'single'},
      diagnostic = {
        signs = {active = signs},
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = {focusable = true, style = 'minimal', border = 'single', source = 'always', header = '', prefix = ''},
      },
    }

    vim.diagnostic.config(config.diagnostic)
    vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, config.float)
    vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, config.float)
    vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, config.float)
  end

  local function on_attach(client, bufnr)
    -- LSP Keymaps
    map('n', 'gd', vim.lsp.buf.definition, {desc = 'Goto Definition'})
    map('n', 'gr', vim.lsp.buf.references, {desc = 'References'})
    map('n', 'K', vim.lsp.buf.hover, {desc = 'Hover'})
    map('n', '<leader>f', vim.lsp.buf.format, {desc = 'Format'})
    map('v', '<leader>f', vim.lsp.buf.format, {desc = 'Format'})
    map('n', '<leader>lr', vim.lsp.buf.rename, {desc = 'Rename'})
    map('n', '<leader>li', ':LspInfo<CR>', {desc = 'Connected Servers'})

    -- Disable Formatting for sumneko-lua
    if client.name == 'lua_ls' then
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
    end
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

  local msls_status_ok, mason_lspconfig = pcall(require, 'mason-lspconfig')
  if not msls_status_ok then return end

  mason_lspconfig.setup({
    ensure_installed = vim.tbl_keys(servers),
    automatic_installation = false,
  })

  -- Set up LSP servers
  local lspconfig = require('lspconfig')
  local lspwin = require('lspconfig.ui.windows')
  lspwin.default_options.border = 'single'
  for server_name, _ in pairs(servers) do
    local options = vim.tbl_deep_extend('force', opts, servers[server_name] or {})
    lspconfig[server_name].setup(options)
  end
end

-- PLUGINS
local plugins = {
  -- Colorschemes
  {'sainnhe/everforest', config = function() vim.cmd('colorscheme everforest') end},
  -- Statusline
  {
    'nvim-lualine/lualine.nvim',
    dependencies = 'kyazdani42/nvim-web-devicons',
    opts = {
      options = {component_separators = '|', section_separators = {left = '', right = ''}},
      sections = {lualine_x = {'fileformat', 'encoding', 'filetype'}, lualine_y = {}, lualine_z = {{'location', separator = {left = '', right = ''}, left_padding = 2}}},
      tabline = { lualine_a = {'buffers'}, lualine_b = {}, lualine_c = {}, lualine_x = {}, lualine_y = {}, lualine_z = {}},
    }
  },
  -- Treesitter
  {
    'nvim-treesitter/nvim-treesitter', build = ':TSUpdate', event = {'BufRead', 'InsertEnter'},
    config = function() require('nvim-treesitter.configs').setup {ensure_installed = {'bash', 'lua', 'python'}, highlight = {enable = true, disable = {''}}, autopairs = {enable = true}} end
  },
  {'windwp/nvim-autopairs', event = 'InsertEnter', opts = {}},
  -- NVimTree
  {'kyazdani42/nvim-tree.lua', cmd = 'NvimTreeToggle', opts = {}},
  -- Git
  {'lewis6991/gitsigns.nvim', event = {'BufRead', 'BufNewFile'}, dependencies = 'nvim-lua/plenary.nvim', opts = {}},
  -- Comment
  {'terrortylor/nvim-comment', name = 'nvim_comment', event = {'BufRead', 'BufNewFile'}, opts = {comment_empty = false}},
  -- WhichKey
  {
    'folke/which-key.nvim',
    opts = {plugins = {marks = false, registers = false, presets = {operators = false, motions = false, text_objects = false, windows = false, nav = false, z = false, g = false}}, window = {border = 'single', padding = {1, 1, 1, 1}}, layout = {align = 'center'}}
  },
  -- Dashboard
  {
    'nvimdev/dashboard-nvim', event = 'VimEnter',
    config = function()
      require('dashboard').setup {
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
            { icon = '󰈔  ', desc = 'New File                                ', action = 'enew | startinsert', key = ' SPC n ' },
            { icon = '  ', desc = 'Config                                  ', action = 'e $MYVIMRC', key = ' SPC E ' },
            { icon = '  ', desc = 'Sync                                    ', action = 'Lazy sync', key = ' SPC s ' },
            { icon = '󰅚  ', desc = 'Quit                                    ', action = 'qa', key = ' SPC q ' }
          },
          footer = { '  ' .. #vim.tbl_keys(require('lazy').plugins()) .. ' plugins' }
        }
      }
    end
  },
  -- CMP
  {
    'hrsh7th/nvim-cmp', event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      {
        'L3MON4D3/LuaSnip',
        dependencies = { 'saadparwaiz1/cmp_luasnip', 'rafamadriz/friendly-snippets' },
        build = 'make install_jsregexp',
        config = function()
          local luasnip = require('luasnip')
          local snip_folder = vim.fn.stdpath('config') .. '/snippets/'
          api.nvim_create_user_command('LuaSnipEdit', 'lua require("luasnip.loaders").edit_snippet_files()', {})

          luasnip.config.set_config({
            history = true,
            ext_base_prio = 200,
            ext_prio_increase = 1,
            updateevents = 'TextChanged,TextChangedI',
            enable_autosnippets = true,
            store_selection_keys = '<C-q>',
          })

          -- luasnip.filetype_extend('all', { '_' })

          -- Load Snippets
          require('luasnip.loaders.from_vscode').lazy_load()
          -- require('luasnip.loaders.from_vscode').lazy_load({ paths = snip_folder })
          require('luasnip.loaders.from_snipmate').lazy_load({ paths = snip_folder })
          -- require('luasnip.loaders.from_lua').lazy_load({ paths = snip_folder })
        end
      },
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      local has_words_before = function()
        local line, col = unpack(api.nvim_win_get_cursor(0))
        return col ~= 0 and api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
      end
      cmp.setup({
        completion = {completeopt = 'menu,menuone,noselect,noinsert', keyword_length = 1},
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert {
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-y>'] = cmp.config.disable,
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm {select = false},
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, {'i', 's'}),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, {'i', 's'}),
        },
        sources = {
          {name = 'nvim_lsp'},
          {name = 'luasnip'},
          {name = 'buffer'},
          {name = 'path'},
        },
        window = {documentation = {border = 'single'}},
      })
      cmp.setup.cmdline('/', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {{name = 'buffer'}},
      })
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources{{name = 'path'}, {name = 'cmdline'}},
      })
    end
  },
  -- LSP
  {
    'neovim/nvim-lspconfig',
    enabled = false,
    event = {'BufReadPre', 'BufNewFile'}, cmd = {'LspInfo', 'LspStart', 'LspInstall', 'LspUninstall'},
    dependencies = {
      {'williamboman/mason.nvim', build = ':MasonUpdate', opts = {ui = {border = 'single'}, ensure_installed = {}}},
      'williamboman/mason-lspconfig.nvim',
      {
        'jose-elias-alvarez/null-ls.nvim',
        config = function()
          local nls = require('null-ls')
          local nlsfmt = nls.builtins.formatting
          nls.setup {border = 'single', debug = false, sources = {nlsfmt.fprettify, nlsfmt.black, nlsfmt.stylua}}
        end,
      },
    },
    config = function() lsp_setup() end
  },
}

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath})
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup(plugins, {ui = {border = 'single'}})
