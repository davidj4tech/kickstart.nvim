local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  { src = gh 'akinsho/toggleterm.nvim', version = vim.version.range '*' }, -- stable releases
}

vim.api.nvim_set_hl(0, 'AgentTerminalInsertBorder', { fg = '#5fb3b3', bold = true })
vim.api.nvim_set_hl(0, 'AgentTerminalNormalBorder', { fg = '#8a8a8a', bold = true })
vim.api.nvim_set_hl(0, 'AgentTerminalInsertWinbar', { fg = '#102020', bg = '#5fb3b3', bold = true })
vim.api.nvim_set_hl(0, 'AgentTerminalNormalWinbar', { fg = '#eeeeee', bg = '#4a4a4a', bold = true })

require('toggleterm').setup {
  direction = 'horizontal',
  size = function(term)
    if term.direction == 'horizontal' then
      return 15
    elseif term.direction == 'vertical' then
      return math.floor(vim.o.columns * 0.4)
    end
  end,
  shade_terminals = true,
  start_in_insert = true,
  persist_size = true,
  persist_mode = true,
  float_opts = { border = 'curved' },
}

vim.keymap.set('n', '<leader>tt', '<cmd>ToggleTermToggleAll<cr>', { desc = '[T]erminal [T]oggle all' })
vim.keymap.set('n', '<leader>tf', function()
  vim.cmd(('%dToggleTerm direction=float'):format(vim.v.count1))
end, { desc = '[T]erminal [F]loat' })
vim.keymap.set('n', '<leader>th', function()
  vim.cmd(('%dToggleTerm direction=horizontal'):format(vim.v.count1))
end, { desc = '[T]erminal [H]orizontal' })
vim.keymap.set('n', '<leader>tv', function()
  vim.cmd(('%dToggleTerm direction=vertical size=80'):format(vim.v.count1))
end, { desc = '[T]erminal [V]ertical' })

function _G.agent_terminal_mode_label()
  local mode = vim.api.nvim_get_mode().mode
  local label = vim.b.agent_terminal_label or 'TERM'
  if mode == 't' then
    return '%#AgentTerminalInsertWinbar# ' .. label .. ' INSERT %#WinBar#'
  elseif mode:match '^nt' or mode == 'n' then
    return '%#AgentTerminalNormalWinbar# ' .. label .. ' NORMAL / SCROLL %#WinBar#'
  end
  return ' ' .. label .. ' '
end

local function set_terminal_chrome(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if vim.bo[bufnr].buftype ~= 'terminal' then return end

  local mode = vim.api.nvim_get_mode().mode
  local border_hl = mode == 't' and 'AgentTerminalInsertBorder' or 'AgentTerminalNormalBorder'
  vim.wo.winbar = '%{%v:lua.agent_terminal_mode_label()%}'
  vim.wo.winhighlight = 'FloatBorder:' .. border_hl
end

local function set_terminal_keymaps(bufnr, label)
  bufnr = bufnr or 0
  if label then vim.b[bufnr].agent_terminal_label = label end
  set_terminal_chrome(bufnr)
  local kopts = { buffer = bufnr, noremap = true, silent = true }
  vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], vim.tbl_extend('force', kopts, { desc = 'Exit terminal mode' }))
  vim.keymap.set('t', 'jk', [[<C-\><C-n>]], vim.tbl_extend('force', kopts, { desc = 'Exit terminal mode' }))
  vim.keymap.set('t', '<PageUp>', [[<C-\><C-n><C-b>]], vim.tbl_extend('force', kopts, { desc = 'Page up terminal scrollback' }))
  vim.keymap.set('t', '<kPageUp>', [[<C-\><C-n><C-b>]], vim.tbl_extend('force', kopts, { desc = 'Page up terminal scrollback' }))
  vim.keymap.set('t', '<C-]>', function()
    vim.api.nvim_chan_send(vim.b.terminal_job_id, '\x1b')
  end, vim.tbl_extend('force', kopts, { desc = 'Send Escape to terminal' }))
  vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], kopts)
  vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], kopts)
  vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], kopts)
  vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], kopts)
end

local Terminal = require('toggleterm.terminal').Terminal
local pi_cmd = vim.env.PI_NVIM_CMD or 'pi'
local claude_cmd = vim.env.CLAUDE_NVIM_CMD or 'claude --dangerously-skip-permissions'
local pi_term = Terminal:new {
  cmd = pi_cmd,
  direction = 'float',
  hidden = true,
  display_name = pi_cmd,
  auto_scroll = false,
  on_open = function(term) set_terminal_keymaps(term.bufnr, 'PI') end,
  on_exit = function()
    if vim.g.pi_exit_nvim then
      vim.schedule(function() vim.cmd 'qall' end)
    end
  end,
  float_opts = {
    border = 'curved',
    width = function() return math.max(20, vim.o.columns - 2) end,
    height = function() return math.max(10, vim.o.lines - 2) end,
    row = 0,
    col = 0,
    title_pos = 'center',
  },
}

local pi_split = Terminal:new {
  cmd = pi_cmd,
  direction = 'horizontal',
  hidden = true,
  display_name = pi_cmd .. ' split',
  auto_scroll = false,
  size = function() return math.floor(vim.o.lines * 0.45) end,
  on_open = function(term) set_terminal_keymaps(term.bufnr, 'PI') end,
}

local claude_term = Terminal:new {
  cmd = claude_cmd,
  direction = 'float',
  hidden = true,
  display_name = claude_cmd,
  auto_scroll = false,
  on_open = function(term) set_terminal_keymaps(term.bufnr, 'CLAUDE') end,
  on_exit = function()
    if vim.g.claude_exit_nvim then
      vim.schedule(function() vim.cmd 'qall' end)
    end
  end,
  float_opts = {
    border = 'curved',
    width = function() return math.max(20, vim.o.columns - 2) end,
    height = function() return math.max(10, vim.o.lines - 2) end,
    row = 0,
    col = 0,
    title_pos = 'center',
  },
}

local claude_split = Terminal:new {
  cmd = claude_cmd,
  direction = 'horizontal',
  hidden = true,
  display_name = claude_cmd .. ' split',
  auto_scroll = false,
  size = function() return math.floor(vim.o.lines * 0.45) end,
  on_open = function(term) set_terminal_keymaps(term.bufnr, 'CLAUDE') end,
}

vim.api.nvim_create_user_command('Pi', function() pi_term:toggle() end, { desc = 'Toggle pi in a floating terminal' })
vim.api.nvim_create_user_command('PiSplit', function() pi_split:toggle() end, { desc = 'Toggle pi in a scrollable split terminal' })
vim.api.nvim_create_user_command('PiOnly', function()
  vim.g.pi_exit_nvim = true
  pi_term:toggle()
end, { desc = 'Open pi and quit Neovim when pi exits' })
vim.api.nvim_create_user_command('Claude', function() claude_term:toggle() end, { desc = 'Toggle Claude in a floating terminal' })
vim.api.nvim_create_user_command('ClaudeSplit', function() claude_split:toggle() end, { desc = 'Toggle Claude in a scrollable split terminal' })
vim.api.nvim_create_user_command('ClaudeOnly', function()
  vim.g.claude_exit_nvim = true
  claude_term:toggle()
end, { desc = 'Open Claude and quit Neovim when Claude exits' })
vim.keymap.set('n', '<leader>tp', function() pi_term:toggle() end, { desc = '[T]erminal [P]i' })
vim.keymap.set('n', '<leader>tP', function() pi_split:toggle() end, { desc = '[T]erminal [P]i split' })
vim.keymap.set('n', '<leader>tc', function() claude_term:toggle() end, { desc = '[T]erminal [C]laude' })
vim.keymap.set('n', '<leader>tC', function() claude_split:toggle() end, { desc = '[T]erminal [C]laude split' })

vim.api.nvim_create_autocmd({ 'TermOpen', 'TermEnter', 'BufWinEnter' }, {
  pattern = 'term://*',
  callback = function(args) set_terminal_keymaps(args.buf) end,
})

vim.api.nvim_create_autocmd('ModeChanged', {
  callback = function()
    set_terminal_chrome()
    vim.cmd 'redrawstatus'
  end,
})
