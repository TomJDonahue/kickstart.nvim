vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.showmode = false

vim.schedule(function() vim.opt.clipboard = 'unnamedplus' end)

vim.opt.breakindent = true
vim.opt.undofile = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.signcolumn = 'yes'

vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.autoindent = true
vim.opt.smarttab = true

vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

vim.opt.inccommand = 'split'

vim.opt.cursorline = true

vim.opt.scrolloff = 8

vim.opt.foldlevelstart = 99

vim.opt.confirm = true

-- [[ Basic Keymaps ]]
vim.keymap.set('n', '<leader>e', '<cmd>Ex<CR>')

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

  jump = { float = true },
}

vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = 'Set Open Float' })
vim.diagnostic.config { jump = { float = true } }

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

vim.pack.add {
  'https://github.com/folke/tokyonight.nvim',
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/lewis6991/gitsigns.nvim',
  'https://github.com/folke/which-key.nvim',
  'https://github.com/nvim-treesitter/nvim-treesitter',
  'https://github.com/folke/todo-comments.nvim',
  'https://github.com/nvim-mini/mini.statusline',
  'https://github.com/windwp/nvim-autopairs',
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/mason-org/mason-lspconfig.nvim',
}

--TODO:HELLO!

require('gitsigns').setup {
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
}

require('which-key').setup {
  delay = 500,
  icons = { mappings = vim.g.have_nerd_font },
}

require('nvim-treesitter').setup {
  -- Directory to install parsers and queries to (prepended to `runtimepath` to have priority)
  install_dir = vim.fn.stdpath 'data' .. '/site',
}

require('nvim-treesitter').install { 'odin', 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' }

vim.api.nvim_create_autocmd('FileType', {
  pattern = '*',
  callback = function(args)
    local ok = pcall(vim.treesitter.start, args.buf)
    if ok then
      vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      vim.wo[0][0].foldmethod = 'expr'
    end
  end,
})

require('tokyonight').setup {
  styles = {
    comments = { italic = false },
  },
}

vim.cmd.colorscheme 'tokyonight-night'

require('todo-comments').setup {
  signs = false,
  keywords = { DEBUG = { icon = '  ', color = 'warning' } },
}

--TODO: Might need to switch this to setup the options on VimEnter? Mimic lazy loading?
vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile' }, {
  callback = function()
    -- Only trigger if the plugin is fully ready
    pcall(function() require('todo-comments.highlight').attach(vim.api.nvim_get_current_buf()) end)
  end,
})

require('mini.statusline').setup {
  use_icons = vim.g.have_nerd_font,
}

require('nvim-autopairs').setup {}
require('mason').setup {}
require('mason-lspconfig').setup {}

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
