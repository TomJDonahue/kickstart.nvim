-- Set <space> as the leader key
-- See `:help mapleader`
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = 'a'
vim.o.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.autoindent = true
vim.opt.smarttab = true
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'

-- Show which line your cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 8

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true

-- MY FIRST EVER KEYMAP! Replacing :Ex with leader + e for easier netrw access
vim.keymap.set('n', '<leader>e', '<cmd>Ex<CR>')

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.keymap.set('n', '<leader>j', '<cmd>%!jq .<CR>')

-- Diagnostic Config & Keymaps
-- See :help vim.diagnostic.Opts
vim.diagnostic.config {
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = vim.diagnostic.severity.ERROR },

  -- Can switch between these as you prefer
  virtual_text = true, -- Text shows up at the end of the line
  virtual_lines = false, -- Teest shows up underneath the line, with virtual lines

  -- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
  jump = { float = true },
}

vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = 'Set Open Float' })
vim.diagnostic.config { jump = { float = true } }
--
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then error('Error cloning lazy.nvim:\n' .. out) end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

require('lazy').setup({
  -- NOTE: Plugins can be added via a link or github org/name. To run setup automatically, use `opts = {}`
  { 'NMAC427/guess-indent.nvim', opts = {} },

  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = true,
    -- use opts = {} for passing setup options
    -- this is equivalent to setup({}) function
  },
  {
    'L3MON4D3/LuaSnip',
    keys = function()
      -- Disable default tab keybinding in LuaSnip
      return {}
    end,
  },

  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
      -- delay between pressing a key and opening which-key (milliseconds)
      delay = 0,
      icons = { mappings = vim.g.have_nerd_font },

      -- Document existing key chains
      spec = {
        { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      },
    },
  },

  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    enabled = true,
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',

        build = 'make',
        cond = function() return vim.fn.executable 'make' == 1 end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },

      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      require('telescope').setup {
        extensions = {
          ['ui-select'] = { require('telescope.themes').get_dropdown() },
        },
      }

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set({ 'n', 'v' }, '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader>sc', builtin.commands, { desc = '[S]earch [C]ommands' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
        callback = function(event)
          local buf = event.buf

          vim.keymap.set('n', 'grr', builtin.lsp_references, { buffer = buf, desc = '[G]oto [R]eferences' })
          vim.keymap.set('n', 'gri', builtin.lsp_implementations, { buffer = buf, desc = '[G]oto [I]mplementation' })
          vim.keymap.set('n', 'grd', builtin.lsp_definitions, { buffer = buf, desc = '[G]oto [D]efinition' })
          vim.keymap.set('n', 'gO', builtin.lsp_document_symbols, { buffer = buf, desc = 'Open Document Symbols' })
          vim.keymap.set('n', 'gW', builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = 'Open Workspace Symbols' })
          vim.keymap.set('n', 'grt', builtin.lsp_type_definitions, { buffer = buf, desc = '[G]oto [T]ype Definition' })
        end,
      })

      vim.keymap.set(
        'n',
        '<leader>/',
        function()
          builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
            winblend = 10,
            previewer = false,
          })
        end,
        { desc = '[/] Fuzzily search in current buffer' }
      )

      vim.keymap.set(
        'n',
        '<leader>s/',
        function()
          builtin.live_grep {
            grep_open_files = true,
            prompt_title = 'Live Grep in Open Files',
          }
        end,
        { desc = '[S]earch [/] in Open Files' }
      )

      vim.keymap.set('n', '<leader>sn', function() builtin.find_files { cwd = vim.fn.stdpath 'config' } end, { desc = '[S]earch [N]eovim files' })
    end,
  },

  -- LSP Plugins
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
      { 'mason-org/mason.nvim', opts = {} },
      { 'mason-org/mason-lspconfig.nvim', opts = {} },
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      { 'j-hui/fidget.nvim', opts = {} },
      'saghen/blink.cmp',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
          map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method('textDocument/documentHighlight', event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          if client and client:supports_method('textDocument/inlayHint', event.buf) then
            map('<leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      local capabilities = require('blink.cmp').get_lsp_capabilities()

      local servers = {
        -- clangd = {},
        -- gopls = {},
        pyright = {},
        -- rust_analyzer = {},
        --
        -- Some languages (like typescript) have entire language plugins that can be useful:
        --    https://github.com/pmizio/typescript-tools.nvim
        --
        -- But for many setups, the LSP (`ts_ls`) will work just fine
        -- ts_ls = {},
      }

      for name, config in pairs(servers) do
        local config = config or {}
        config.capabilities = vim.tbl_deep_extend('force', {}, capabilities, config.capabilities or {})
        vim.lsp.config(name, config)
        vim.lsp.enable(name)
      end
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'lua_ls', -- Lua Language server
        'stylua', -- Used to format Lua code
      })

      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      for name, server in pairs(servers) do
        server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
        vim.lsp.config(name, server)
        vim.lsp.enable(name)
      end

      -- Special Lua Config, as recommended by neovim help docs
      vim.lsp.config('lua_ls', {
        on_init = function(client)
          if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
          end

          client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
            runtime = {
              version = 'LuaJIT',
              path = { 'lua/?.lua', 'lua/?/init.lua' },
            },
            workspace = {
              checkThirdParty = false,
              -- NOTE: this is a lot slower and will cause issues when working on your own configuration.
              --  See https://github.com/neovim/nvim-lspconfig/issues/3189
              library = vim.api.nvim_get_runtime_file('', true),
            },
          })
        end,
        settings = {
          Lua = {},
        },
      })
      vim.lsp.enable 'lua_ls'
    end,
  },

  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function() require('conform').format { async = true, lsp_format = 'fallback' } end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        local disable_filetypes = { c = true, cpp = true }
        if disable_filetypes[vim.bo[bufnr].filetype] then
          return nil
        else
          return {
            timeout_ms = 500,
            lsp_format = 'fallback',
          }
        end
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        python3 = { 'isort', 'black' },
        -- go = { 'goimports', 'gopls' },
        odin = { 'odinfmt' },
      },
    },
  },

  { -- Autocompletion
    'saghen/blink.cmp',
    event = 'VimEnter',
    version = '1.*',
    dependencies = {
      -- Snippet Engine
      {
        'L3MON4D3/LuaSnip',
        version = '2.*',
        build = (function()
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then return end
          return 'make install_jsregexp'
        end)(),
        dependencies = {},
        opts = {},
      },
    },
    --- @module 'blink.cmp'
    --- @type blink.cmp.Config
    opts = {
      keymap = {

        preset = 'default',
      },

      appearance = {
        nerd_font_variant = 'mono',
      },

      completion = {
        -- By default, you may press `<c-space>` to show the documentation.
        -- Optionally, set `auto_show = true` to show the documentation after a delay.
        documentation = { auto_show = false, auto_show_delay_ms = 500 },
      },

      sources = {
        default = { 'lsp', 'path', 'snippets' },
      },

      snippets = { preset = 'luasnip' },

      fuzzy = { implementation = 'lua' },

      signature = { enabled = true },
    },
  },

  {
    'folke/tokyonight.nvim',
    priority = 1000,
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require('tokyonight').setup {
        styles = {
          comments = { italic = false },
        },
      }

      vim.cmd.colorscheme 'tokyonight-night'
    end,
  },

  -- Highlight todo, notes, etc in comments
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false, keywords = { DEBUG = { icon = '  ', color = 'warning' } } },
  },

  { -- Collection of various small independent plugins/modules
    'nvim-mini/mini.nvim',
    config = function()
      require('mini.ai').setup { n_lines = 500 }
      require('mini.surround').setup()
      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = vim.g.have_nerd_font }
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function() return '%2l:%-2v' end
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
    config = function()
      local ts = require 'nvim-treesitter'
      local parsers = { 'odin', 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' }

      for _, parser in ipairs(parsers) do
        pcall(ts.install, parser)
      end

      vim.api.nvim_create_autocmd('FileType', {
        callback = function() pcall(vim.treesitter.start) end,
      })
    end,
  },
}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})
-- Project runner configuration
local runners = {
  odin = function()
    -- Check if there's an ols.json or build.bat/build.sh
    if vim.fn.filereadable 'build.sh' == 1 then
      return 'bash build.sh'
    elseif vim.fn.filereadable 'build.bat' == 1 then
      return 'build.bat'
    else
      -- Default: build and run main package
      return 'odin run .'
    end
  end,

  python = function() return 'python3 ' .. vim.fn.expand '%' end,

  go = function() return 'go run .' end,

  c = function()
    if vim.fn.filereadable 'Makefile' == 1 then
      return 'make run'
    else
      return 'gcc ' .. vim.fn.expand '%' .. ' -o out && ./out'
    end
  end,
}

-- Main run function
local function run_project()
  --Save all modified buffers
  vim.cmd 'silent! wall'

  local ft = vim.bo.filetype
  local runner = runners[ft]

  if runner then
    local cmd = runner()
    -- Open terminal in vertical split and run command
    vim.cmd 'vsplit'
    vim.cmd('terminal ' .. cmd)
    -- Enter insert mode in terminal
    vim.cmd 'startinsert'
  else
    print('No runner configured for filetype: ' .. ft)
  end
end

-- Keybinding (using <leader>r, change to your preference)
vim.keymap.set('n', '<leader>r', run_project, { desc = 'Run project' })

-- Alternative: use F5 instead
-- vim.keymap.set('n', '<F5>', run_project, { desc = 'Run project' })
--
-- Compiler configuration (add this near your runners config)
local compilers = {
  odin = function()
    return {
      makeprg = 'odin check .',
      errorformat = '%f(%l:%c) %m',
    }
  end,

  python = function()
    return {
      makeprg = 'python3 ' .. vim.fn.expand '%',
      errorformat = [[%C %.%#,%A  File "%f"\, line %l%.%#,%Z%[%^ ]%\@=%m]],
    }
  end,

  go = function()
    return {
      makeprg = 'go build ./...',
      errorformat = '%f:%l:%c: %m,%f:%l: %m',
    }
  end,

  c = function()
    if vim.fn.filereadable 'Makefile' == 1 then
      return {
        makeprg = 'make',
        errorformat = '%f:%l:%c: %m,%f:%l: %m',
      }
    else
      return {
        makeprg = 'gcc -Wall ' .. vim.fn.expand '%' .. ' -o out',
        errorformat = '%f:%l:%c: %m,%f:%l: %m',
      }
    end
  end,

  rust = function()
    return {
      makeprg = 'cargo build',
      errorformat = [[%Eerror: %m,%Eerror[E%n]: %m,%Wwarning: %m,%Inote: %m,%C %#--> %f:%l:%c]],
    }
  end,
}

-- Setup compiler for current filetype
local function setup_compiler()
  local ft = vim.bo.filetype
  local compiler = compilers[ft]

  if compiler then
    local config = compiler()
    vim.opt_local.makeprg = config.makeprg
    vim.opt_local.errorformat = config.errorformat
  end
end

-- Auto-setup compiler when entering buffers
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufNewFile' }, {
  pattern = '*',
  callback = setup_compiler,
})

-- Convert quickfix list to diagnostics
local function quickfix_to_diagnostics()
  local qflist = vim.fn.getqflist()
  local diagnostics_by_buf = {}

  -- Clear all previous build diagnostics
  local ns = vim.api.nvim_create_namespace 'build_diagnostics'
  vim.diagnostic.reset(ns)

  -- Group diagnostics by buffer
  for _, item in ipairs(qflist) do
    if item.bufnr > 0 and item.valid == 1 then
      if not diagnostics_by_buf[item.bufnr] then diagnostics_by_buf[item.bufnr] = {} end

      -- Determine severity (E=error, W=warning, default to error)
      local severity = vim.diagnostic.severity.ERROR
      if item.type == 'W' or item.type == 'w' then
        severity = vim.diagnostic.severity.WARN
      elseif item.type == 'I' or item.type == 'i' then
        severity = vim.diagnostic.severity.INFO
      elseif item.type == 'N' or item.type == 'n' then
        severity = vim.diagnostic.severity.HINT
      end

      table.insert(diagnostics_by_buf[item.bufnr], {
        lnum = item.lnum - 1, -- 0-indexed
        col = item.col - 1, -- 0-indexed
        message = item.text,
        severity = severity,
        source = 'build',
      })
    end
  end

  -- Set diagnostics for each buffer
  for bufnr, diagnostics in pairs(diagnostics_by_buf) do
    vim.diagnostic.set(ns, bufnr, diagnostics, {})
  end
end

-- Build function with quickfix and diagnostics
local function build_project()
  -- Save all modified buffers
  vim.cmd 'silent! wall'
  vim.cmd 'cclose'

  -- Setup compiler for current filetype
  setup_compiler()

  -- Run make and open quickfix
  vim.cmd 'silent make!'
  vim.cmd 'redraw!'

  -- Convert quickfix to diagnostics
  quickfix_to_diagnostics()

  -- Open quickfix only if there are errors
  -- local qflist = vim.fn.getqflist() --changed to querying diagnostics instead of quickfix.
  -- Python seems to output into quickfix regardless of errors or not.
  local dlist = vim.diagnostic.get()
  if #dlist > 0 then vim.cmd 'copen' end
end

-- Keybinding (using <leader>b for build)
vim.keymap.set('n', '<leader>b', build_project, { desc = 'Build project and show errors' })

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
