
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.o.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
vim.o.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.o.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.o.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.o.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Configure the tab width
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.autoindent = true
vim.opt.smarttab = true
-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
--
--  Notice listchars is set using `vim.opt` instead of `vim.o`.
--  It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
--   See `:help lua-options`
--   and `:help lua-guide-options`
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

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- MY FIRST EVER KEYMAP! Replacing :Ex with leader + e for easier netrw access
vim.keymap.set('n', '<leader>e', '<cmd>Ex<CR>')

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

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
--
--MY FOURTH KEYMAP. Diagnostic navigation and floating diagnostics
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = 'Set Open Float' })
vim.diagnostic.config { jump = { float = true } }
-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
-- vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
-- vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
-- vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
-- vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then error('Error cloning lazy.nvim:\n' .. out) end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
-- NOTE: Here is where you install your plugins.
require('lazy').setup({
  -- NOTE: Plugins can be added via a link or github org/name. To run setup automatically, use `opts = {}`
  { 'NMAC427/guess-indent.nvim', opts = {} },

  {
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
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
      -- delay between pressing a key and opening which-key (milliseconds)
      delay = 500,
      icons = { mappings = vim.g.have_nerd_font },

      -- Document existing key chains
      spec = {
        { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      },
    },
  },

  {
    'nvim-telescope/telescope.nvim',
    enabled = true,
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
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

      -- Override default behavior and theme when searching
      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      --  See `:help telescope.builtin.live_grep()` for information about particular keys
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

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set('n', '<leader>sn', function() builtin.find_files { cwd = vim.fn.stdpath 'config' } end, { desc = '[S]earch [N]eovim files' })
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
  {
    'folke/tokyonight.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    config = function()
      require('tokyonight').setup {
        styles = {
          comments = { italic = false },
        },
      }

      vim.cmd.colorscheme 'tokyonight-night'
    end,
  },

  { -- Highlight todo, notes, etc in comments
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false, keywords = { DEBUG = { icon = '  ', color = 'warning' } } },
  },

  { -- Collection of various small independent plugins/modules
    'nvim-mini/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      -- Simple and easy statusline.
      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = vim.g.have_nerd_font }

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function() return '%2l:%-2v' end
    end,
  },

}, 
{
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
    if vim.fn.filereadable('build.sh') == 1 then
      return 'bash build.sh'
    elseif vim.fn.filereadable('build.bat') == 1 then
      return 'build.bat'
    else
      -- Default: build and run main package
      return 'odin run .'
    end
  end,
  
  python = function()
    return 'python3 ' .. vim.fn.expand('%')
  end,
  
  go = function()
    return 'go run .'
  end,
  
  c = function()
    if vim.fn.filereadable('Makefile') == 1 then
      return 'make run'
    else
      return 'gcc ' .. vim.fn.expand('%') .. ' -o out && ./out'
    end
  end,
}

-- Main run function
local function run_project()

  --Save all modified buffers
  vim.cmd('silent! wall')

  local ft = vim.bo.filetype
  local runner = runners[ft]
  
  if runner then
    local cmd = runner()
    -- Open terminal in vertical split and run command
    vim.cmd('vsplit')
    vim.cmd('terminal ' .. cmd)
    -- Enter insert mode in terminal
    vim.cmd('startinsert')
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
      makeprg = "odin check .",
      errorformat = "%f(%l:%c) %m",
    }
  end,
  
  python = function()
    return {
      makeprg = "python3 " .. vim.fn.expand('%'),
      errorformat = [[%C %.%#,%A  File "%f"\, line %l%.%#,%Z%[%^ ]%\@=%m]],
    }
  end,
  
  go = function()
    return {
      makeprg = "go build ./...",
      errorformat = "%f:%l:%c: %m,%f:%l: %m",
    }
  end,
  
  c = function()
    if vim.fn.filereadable('Makefile') == 1 then
      return {
        makeprg = "make",
        errorformat = "%f:%l:%c: %m,%f:%l: %m",
      }
    else
      return {
        makeprg = "gcc -Wall " .. vim.fn.expand('%') .. " -o out",
        errorformat = "%f:%l:%c: %m,%f:%l: %m",
      }
    end
  end,
  
  rust = function()
    return {
      makeprg = "cargo build",
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
vim.api.nvim_create_autocmd({"BufEnter", "BufNewFile"}, {
  pattern = "*",
  callback = setup_compiler,
})

-- Convert quickfix list to diagnostics
local function quickfix_to_diagnostics()
  local qflist = vim.fn.getqflist()
  local diagnostics_by_buf = {}
  
  -- Clear all previous build diagnostics
  local ns = vim.api.nvim_create_namespace("build_diagnostics")
  vim.diagnostic.reset(ns)
  
  -- Group diagnostics by buffer
  for _, item in ipairs(qflist) do
    if item.bufnr > 0 and item.valid == 1 then
      if not diagnostics_by_buf[item.bufnr] then
        diagnostics_by_buf[item.bufnr] = {}
      end
      
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
        lnum = item.lnum - 1,  -- 0-indexed
        col = item.col - 1,    -- 0-indexed
        message = item.text,
        severity = severity,
        source = "build",
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
  vim.cmd('silent! wall')
  vim.cmd('cclose')
  
  -- Setup compiler for current filetype
  setup_compiler()
  
  -- Run make and open quickfix
  vim.cmd('silent make!')
  vim.cmd('redraw!')
  
  -- Convert quickfix to diagnostics
  quickfix_to_diagnostics()
  
  -- Open quickfix only if there are errors
  -- local qflist = vim.fn.getqflist() --changed to querying diagnostics instead of quickfix. 
  -- Python seems to output into quickfix regardless of errors or not.
  local dlist = vim.diagnostic.get()
  if #dlist > 0 then
    vim.cmd('copen')
  end
end

-- Keybinding (using <leader>b for build)
vim.keymap.set('n', '<leader>b', build_project, { desc = 'Build project and show errors' })



-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
