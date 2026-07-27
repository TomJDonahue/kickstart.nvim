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
