-- LSP
local lsp = false

-- OPTIONS
local o = vim.opt
local api = vim.api
local map = vim.keymap.set
local aucmd = vim.api.nvim_create_autocmd

o.nu = true -- line number
o.rnu = false -- relative line number
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
o.ru = false
o.mouse = 'a'
o.winborder = 'single'

-- COLORSCHEMES
vim.cmd('colorscheme habamax')

-- AUTOCOMMANDS
aucmd('TextYankPost', {pattern = '*', command = 'lua vim.highlight.on_yank()'}) -- highlight on yank
aucmd({'FocusGained', 'TermClose', 'TermLeave'}, {command = 'checktime'}) -- reload changed file
aucmd({'BufWinEnter', 'BufEnter'}, {command = 'set formatoptions-=cro'}) -- don't auto comment new line
aucmd('TermOpen', {pattern = '*', command = 'startinsert'}) -- open terminal in insert mode
aucmd('BufReadPost', {command = [[if line("'\"") > 1 && line("'\"") <= line("$") | execute "normal! g`\"" | endif]]}) -- restore cursor position
aucmd('FileType', {pattern = {'checkhealth', 'help', 'lspinfo', 'man', 'qf', 'startuptime'}, command = 'nnoremap <buffer><silent> q :q!<CR>'}) -- windows to close with 'q'

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
map('n', '<leader>n', ':ene <BAR> startinsert<CR>', {desc = 'New File'})
map('n', '<Leader>k', 'gcc', {desc = 'Comment', remap = true})
map('v', '<Leader>k', 'gc', {desc = 'Comment', remap = true})
map({'i','n','v'}, '<C-s>', '<ESC>:w<CR><ESC>')
map({'i','n','v'}, '<C-w>', '<ESC>:bd<CR><ESC>')
map({'i','n','v'}, '<C-q>', '<ESC>:q!<CR>')

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
  {'lewis6991/gitsigns.nvim', event = {'BufRead', 'BufNewFile'}, opts = {}},
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
    'saghen/blink.cmp', event = 'InsertEnter',
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        build = 'make install_jsregexp',
        config = function()
          local snip_folder = vim.fn.stdpath('config') .. '/snippets/'
          api.nvim_create_user_command('LuaSnipEdit', 'lua require("luasnip.loaders").edit_snippet_files()', {})
          require('luasnip').setup({history = true, enable_autosnippets = true, update_events = {'TextChanged', 'TextChangedI'}, store_selection_keys = '<C-q>'})

          -- Load Snippets
          require('luasnip.loaders.from_snipmate').lazy_load { paths = snip_folder }
          -- require('luasnip.loaders.from_vscode').lazy_load { paths = snip_folder }
          -- require('luasnip.loaders.from_lua').lazy_load { paths = snip_folder }
        end
      },
    },
    version = '1.*',
    opts = {
      keymap = {
        preset = 'enter',
        ['<Tab>'] = {'select_next', 'snippet_forward', 'fallback'},
        ['<S-Tab>'] = {'select_prev', 'snippet_backward', 'fallback'},
      },
      completion = {
        accept = {auto_brackets = {enabled = true}},
        documentation = {auto_show = true},
        menu = {draw = {columns = {{'label', 'label_description', 'source_name', gap = 1}}}},
      },
      signature = {enabled = true},
      snippets = {preset = 'luasnip'},
    },
  },
  -- LSP
  {
    'neovim/nvim-lspconfig',
    enabled = lsp,
    event = {'BufReadPre', 'BufNewFile'},
    dependencies = {
      {'mason-org/mason.nvim', build = ':MasonUpdate', opts = {ensure_installed = {}}},
      {'mason-org/mason-lspconfig.nvim', opts = {automatic_enable = true}},
      'saghen/blink.cmp', 'nvim-lua/plenary.nvim',
      {
        'nvimtools/none-ls.nvim',
        config = function()
          local nls = require('null-ls')
          local nlsfmt = nls.builtins.formatting
          nls.setup {sources = {nlsfmt.fprettify, nlsfmt.black, nlsfmt.stylua}}
        end,
      },
    },
    config = function()
      -- Diagnostic Signs
      vim.diagnostic.config({signs = { text = { [vim.diagnostic.severity.ERROR] = '󰅚', [vim.diagnostic.severity.WARN] = '', [vim.diagnostic.severity.HINT] = '', [vim.diagnostic.severity.INFO] = '' } }, severity_sort = true, float = {}})

      -- Servers
      local function on_attach(client, bufnr)
        -- Keymaps
        map('n', 'gd', vim.lsp.buf.definition, {desc = 'Goto Definition'})
        map('n', 'gr', vim.lsp.buf.references, {desc = 'References'})
        map('n', '<leader>f', vim.lsp.buf.format, {desc = 'Format'})
        map('v', '<leader>f', vim.lsp.buf.format, {desc = 'Format'})
        map('n', '<leader>la', vim.lsp.buf.code_action, {desc = 'Action'})
        map('n', '<leader>lr', vim.lsp.buf.rename, {desc = 'Rename'})
        map('n', '<leader>li', ':LspInfo<CR>', {desc = 'Connected Servers'})

        -- Disable formatting for lua_ls
        if client.name == 'lua_ls' then
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
        end
      end

      local capabilities = require('blink.cmp').get_lsp_capabilities(vim.lsp.protocol.make_client_capabilities())
      vim.lsp.config('*', {on_attach = on_attach, capabilities = capabilities})
      vim.lsp.enable({'fortls', 'pyright', 'lua_ls'})
    end,
  },
}

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath})
end
o.rtp:prepend(lazypath)
require('lazy').setup(plugins)
