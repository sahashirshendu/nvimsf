-- LSP
local lsp = false

-- OPTIONS
local o = vim.opt
local api = vim.api
local map = vim.keymap.set

o.nu = true -- Line Number
o.rnu = false -- Relative line number
o.tgc = true
o.tm = 500
o.ut = 500
o.scl = 'yes'
o.cul = true
o.et = true
o.cin = true
o.wrap = false
o.tw = 300
o.ts = 2
o.sw = 2
o.sts = -1
o.smd = false
o.ww = 'b,s,<,>,[,],h,l'
o.ph = 10
o.pb = 10
o.cb = 'unnamed,unnamedplus'
o.ic = true
o.scs = true
o.wb = false
o.swf = false
o.hi = 100
o.spr = true
o.sb = true
o.mouse = 'a'
o.ru = false

-- COLORSCHEMES
vim.cmd('colorscheme retrobox')

-- AUTOCOMMANDS
api.nvim_create_autocmd('TextYankPost', {pattern = '*', command = 'lua vim.highlight.on_yank()'}) -- highlight on yank
api.nvim_create_autocmd({'FocusGained', 'TermClose', 'TermLeave'}, {command = 'checktime'}) -- reload changed file
api.nvim_create_autocmd({'BufWinEnter', 'BufEnter'}, {command = 'set formatoptions-=cro'}) -- don't auto comment new line
api.nvim_create_autocmd('TermOpen', {pattern = '*', command = 'startinsert'}) -- open terminal in insert mode
api.nvim_create_autocmd('BufReadPost', {command = [[if line("'\"") > 1 && line("'\"") <= line("$") | execute "normal! g`\"" | endif]]}) -- restore cursor position
api.nvim_create_autocmd('FileType', {pattern = {'checkhealth', 'help', 'lspinfo', 'man', 'qf', 'startuptime'}, command = 'nnoremap <buffer><silent> q :q!<CR>'}) -- windows to close with 'q'

-- KEYBINDINGS
vim.g.mapleader = ','

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
map('n', '<leader>c', ':e $MYVIMRC<CR>', {desc = 'Config'})
map('n', '<leader>e', ':NvimTreeToggle<CR>', {desc = 'Files'})
map('n', '<leader>s', ':Lazy sync<CR>', {desc = 'Update Plugins'})
map('n', '<leader>n', ':enew <BAR> startinsert<CR>', {desc = 'New File'})
map({'n'}, '<Leader>k', 'gcc', {desc = 'Comment', remap = true})
map({'v'}, '<Leader>k', 'gc', {desc = 'Comment', remap = true})
map({'i','n','v'}, '<C-s>', '<ESC>:w<CR><ESC>')
map({'i','n','v'}, '<C-w>', '<ESC>:bd<CR><ESC>')
map({'i','n','v'}, '<C-q>', '<ESC>:q!<CR>')

-- LSP
local function lsp_setup()
  local function lsp_init()
    -- Diagnostic Signs
    local signs = {Error = '', Warn = '', Hint = '󰌬', Info = ''}
    for type, icon in pairs(signs) do
      local hl = 'DiagnosticSign' .. type
      vim.fn.sign_define(hl, {text = icon, texthl = hl, numhl = ''})
    end

    vim.diagnostic.config({signs = {active = signs}, severity_sort = true, float = {}})
    vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {})
    vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, {})
  end

  local function on_attach(client, bufnr)
    -- LSP Keymaps
    map('n', 'gd', vim.lsp.buf.definition, {desc = 'Goto Definition'})
    map('n', 'gr', vim.lsp.buf.references, {desc = 'References'})
    map('n', '<leader>f', vim.lsp.buf.format, {desc = 'Format'})
    map('v', '<leader>f', vim.lsp.buf.format, {desc = 'Format'})
    map('n', '<leader>la', vim.lsp.buf.code_action, {desc = 'Action'})
    map('n', '<leader>lr', vim.lsp.buf.rename, {desc = 'Rename'})
    map('n', '<leader>li', ':LspInfo<CR>', {desc = 'Connected Servers'})

    -- Disable Formatting for sumneko-lua
    if client.name == 'lua_ls' then
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
    end
  end

  -- LSP setup --
  lsp_init()

  local capabilities = require('cmp_nvim_lsp').default_capabilities()
  require('mason-lspconfig').setup({automatic_installation = true})

  -- Set up servers
  local lspconfig = require('lspconfig')
  lspconfig.pyright.setup {on_attach = on_attach, capabilities = capabilities}
  lspconfig.fortls.setup {on_attach = on_attach, capabilities = capabilities}
  lspconfig.lua_ls.setup {on_attach = on_attach, capabilities = capabilities}
end

-- PLUGINS
local plugins = {
  -- Statusline
  {
    'nvim-lualine/lualine.nvim',
    dependencies = 'kyazdani42/nvim-web-devicons',
    event = { 'BufRead', 'BufNewFile' },
    opts = {
      options = {component_separators = '|', section_separators = {left = '', right = ''}},
      sections = {lualine_x = {'fileformat', 'encoding', 'filetype'}, lualine_y = {}, lualine_z = {{'location', separator = {left = '', right = ''}, left_padding = 2}}},
      tabline = { lualine_a = {'buffers'}, lualine_b = {}, lualine_c = {}, lualine_x = {}, lualine_y = {}, lualine_z = {}},
    }
  },
  -- Treesitter
  {
    'nvim-treesitter/nvim-treesitter', build = ':TSUpdate', event = {'BufRead', 'InsertEnter'},
    config = function() require('nvim-treesitter.configs').setup {highlight = {enable = true, disable = {''}}, autopairs = {enable = true}} end
  },
  {'windwp/nvim-autopairs', event = 'InsertEnter', opts = {}},
  -- NVimTree
  {'kyazdani42/nvim-tree.lua', cmd = 'NvimTreeToggle', opts = {}},
  -- Git
  {'lewis6991/gitsigns.nvim', event = {'BufRead', 'BufNewFile'}, dependencies = 'nvim-lua/plenary.nvim', opts = {}},
  -- Help
  {'echasnovski/mini.clue', keys = '<leader>', opts = {triggers = {{mode = 'n', keys = '<Leader>'}, {mode = 'x', keys = '<Leader>'}}}},
  -- Dashboard
  {
    'nvimdev/dashboard-nvim',
    config = function()
      require('dashboard').setup {
        theme = 'doom',
        config = {
          header = { '', '', '󱇧  NEOVIM', '', '' },
          center = {
            { desc = 'New File                      ', action = 'enew | startinsert', key = ',n' },
            { desc = 'Config                        ', action = 'e $MYVIMRC', key = ',c' },
            { desc = 'Sync                          ', action = 'Lazy sync', key = ',s' },
            { desc = 'Quit                          ', action = 'qa', key = ',q' }
          },
          footer = { #vim.tbl_keys(require('lazy').plugins()) .. ' plugins' }
        }
      }
    end
  },
  -- CMP
  {
    'hrsh7th/nvim-cmp', event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      {
        'L3MON4D3/LuaSnip',
        dependencies = {'saadparwaiz1/cmp_luasnip'},
        build = 'make install_jsregexp',
        config = function()
          local luasnip = require('luasnip')
          local snip_folder = vim.fn.stdpath('config') .. '/snippets/'
          api.nvim_create_user_command('LuaSnipEdit', 'lua require("luasnip.loaders").edit_snippet_files()', {})

          luasnip.config.set_config({
            history = true,
            enable_autosnippets = true,
            update_events = 'TextChanged,TextChangedI',
            store_selection_keys = '<C-q>',
          })

          -- Load Snippets
          require('luasnip.loaders.from_snipmate').lazy_load({ paths = snip_folder })
          -- require('luasnip.loaders.from_vscode').lazy_load({ paths = snip_folder })
          -- require('luasnip.loaders.from_lua').lazy_load({ paths = snip_folder })
        end
      },
    },
    config = function()
      local cmp = require('cmp')
      cmp.setup({
        completion = {completeopt = 'menu,menuone,noselect,noinsert'},
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert {
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping.select_next_item({behavior = cmp.SelectBehavior.Select}),
          ['<S-Tab>'] = cmp.mapping.select_prev_item({behavior = cmp.SelectBehavior.Select}),
        },
        sources = {
          {name = 'nvim_lsp'},
          {name = 'luasnip'},
          {name = 'buffer'},
          {name = 'path'},
        },
      })
      cmp.setup.cmdline('/', {mapping = cmp.mapping.preset.cmdline(), sources = {{name = 'buffer'}}})
      cmp.setup.cmdline(':', {mapping = cmp.mapping.preset.cmdline(), sources = cmp.config.sources{{name = 'path'}, {name = 'cmdline'}}})
    end
  },
  -- LSP
  {
    'neovim/nvim-lspconfig',
    enabled = lsp,
    event = {'BufReadPre', 'BufNewFile'},
    dependencies = {
      {'williamboman/mason.nvim', build = ':MasonUpdate', opts = {ensure_installed = {}}},
      'williamboman/mason-lspconfig.nvim', 'hrsh7th/nvim-cmp','hrsh7th/cmp-nvim-lsp',
      {
        'nvimtools/none-ls.nvim',
        config = function()
          local nls = require('null-ls')
          local nlsfmt = nls.builtins.formatting
          nls.setup {sources = {nlsfmt.fprettify, nlsfmt.black, nlsfmt.stylua}}
        end,
      },
    },
    config = lsp_setup,
  },
}

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath})
end
o.rtp:prepend(lazypath)
require('lazy').setup(plugins)
