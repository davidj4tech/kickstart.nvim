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

local terminal_scroll_locks = {}

local function is_agent_terminal(bufnr)
  return vim.bo[bufnr].buftype == 'terminal' and vim.b[bufnr].agent_terminal_label ~= nil
end

local function should_lock_terminal_view()
  local mode = vim.api.nvim_get_mode().mode
  return mode == 'n' or mode == 'nt'
end

local function is_terminal_scroll_mode()
  local mode = vim.api.nvim_get_mode().mode
  return mode:match '^n' ~= nil
end

local unlock_terminal_view

local function terminal_view_is_at_bottom(winid)
  winid = winid or vim.api.nvim_get_current_win()
  if not vim.api.nvim_win_is_valid(winid) then return false end

  local bufnr = vim.api.nvim_win_get_buf(winid)
  if not is_agent_terminal(bufnr) then return false end

  local info = vim.fn.getwininfo(winid)[1]
  return info ~= nil and info.botline >= vim.api.nvim_buf_line_count(bufnr)
end

local function enter_terminal_insert_at_bottom(winid)
  winid = winid or vim.api.nvim_get_current_win()
  if not is_terminal_scroll_mode() or not terminal_view_is_at_bottom(winid) then return end

  unlock_terminal_view(winid)
  vim.schedule(function()
    if vim.api.nvim_get_current_win() == winid and terminal_view_is_at_bottom(winid) then
      vim.cmd 'startinsert'
    end
  end)
end

unlock_terminal_view = function(winid)
  winid = winid or vim.api.nvim_get_current_win()
  local lock = terminal_scroll_locks[winid]
  if lock and lock.timer then
    lock.timer:stop()
    lock.timer:close()
  end
  terminal_scroll_locks[winid] = nil
end

local function unlock_terminal_buffer(bufnr)
  for winid, lock in pairs(terminal_scroll_locks) do
    if lock.bufnr == bufnr then unlock_terminal_view(winid) end
  end
end

local function lock_terminal_view(winid)
  winid = winid or vim.api.nvim_get_current_win()
  if not vim.api.nvim_win_is_valid(winid) or not should_lock_terminal_view() then return end

  local bufnr = vim.api.nvim_win_get_buf(winid)
  if not is_agent_terminal(bufnr) then return end

  local lock = terminal_scroll_locks[winid]
  if not lock then
    lock = { bufnr = bufnr, view = vim.fn.winsaveview(), restoring = false }
    terminal_scroll_locks[winid] = lock
  else
    lock.bufnr = bufnr
    lock.view = vim.fn.winsaveview()
  end

  if lock.timer then return end

  lock.timer = vim.uv.new_timer()
  lock.timer:start(50, 50, vim.schedule_wrap(function()
    local active_lock = terminal_scroll_locks[winid]
    if not active_lock then return end
    if not should_lock_terminal_view() then
      unlock_terminal_view(winid)
      return
    end
    if not vim.api.nvim_win_is_valid(winid) or not vim.api.nvim_buf_is_valid(active_lock.bufnr) then
      unlock_terminal_view(winid)
      return
    end

    active_lock.restoring = true
    vim.api.nvim_win_call(winid, function()
      local current_view = vim.fn.winsaveview()
      vim.fn.winrestview(vim.tbl_extend('force', current_view, {
        topline = active_lock.view.topline,
        topfill = active_lock.view.topfill,
        leftcol = active_lock.view.leftcol,
        skipcol = active_lock.view.skipcol,
      }))
    end)
    active_lock.restoring = false
  end))
end

local function set_terminal_keymaps(bufnr, label)
  bufnr = bufnr or 0
  label = label or vim.b[bufnr].agent_terminal_label
  if label then vim.b[bufnr].agent_terminal_label = label end
  set_terminal_chrome(bufnr)
  local kopts = { buffer = bufnr, noremap = true, silent = true }
  vim.keymap.set('t', 'jk', [[<C-\><C-n>]], vim.tbl_extend('force', kopts, { desc = 'Exit terminal mode' }))
  vim.keymap.set('t', '<PageUp>', [[<C-\><C-n><C-b>]], vim.tbl_extend('force', kopts, { desc = 'Page up terminal scrollback' }))
  vim.keymap.set('t', '<kPageUp>', [[<C-\><C-n><C-b>]], vim.tbl_extend('force', kopts, { desc = 'Page up terminal scrollback' }))
  vim.keymap.set('t', '<C-PageUp>', [[<C-\><C-n>gg]], vim.tbl_extend('force', kopts, { desc = 'Top of terminal scrollback' }))
  vim.keymap.set('t', '<C-kPageUp>', [[<C-\><C-n>gg]], vim.tbl_extend('force', kopts, { desc = 'Top of terminal scrollback' }))
  vim.keymap.set('t', '<S-PageUp>', [[<C-\><C-n>gg]], vim.tbl_extend('force', kopts, { desc = 'Top of terminal scrollback' }))
  vim.keymap.set('t', '<S-kPageUp>', [[<C-\><C-n>gg]], vim.tbl_extend('force', kopts, { desc = 'Top of terminal scrollback' }))
  vim.keymap.set('t', '<C-PageDown>', [[<C-\><C-n>G]], vim.tbl_extend('force', kopts, { desc = 'Bottom of terminal scrollback' }))
  vim.keymap.set('t', '<C-kPageDown>', [[<C-\><C-n>G]], vim.tbl_extend('force', kopts, { desc = 'Bottom of terminal scrollback' }))
  vim.keymap.set('t', '<S-PageDown>', [[<C-\><C-n>G]], vim.tbl_extend('force', kopts, { desc = 'Bottom of terminal scrollback' }))
  vim.keymap.set('t', '<S-kPageDown>', [[<C-\><C-n>G]], vim.tbl_extend('force', kopts, { desc = 'Bottom of terminal scrollback' }))
  vim.keymap.set('t', '<C-Up>', [[<C-\><C-n>gg]], vim.tbl_extend('force', kopts, { desc = 'Top of terminal scrollback' }))
  vim.keymap.set('t', '<C-Down>', [[<C-\><C-n>G]], vim.tbl_extend('force', kopts, { desc = 'Bottom of terminal scrollback' }))
  vim.keymap.set('n', '<C-PageUp>', 'gg', vim.tbl_extend('force', kopts, { desc = 'Top of terminal scrollback' }))
  vim.keymap.set('n', '<C-kPageUp>', 'gg', vim.tbl_extend('force', kopts, { desc = 'Top of terminal scrollback' }))
  vim.keymap.set('n', '<S-PageUp>', 'gg', vim.tbl_extend('force', kopts, { desc = 'Top of terminal scrollback' }))
  vim.keymap.set('n', '<S-kPageUp>', 'gg', vim.tbl_extend('force', kopts, { desc = 'Top of terminal scrollback' }))
  vim.keymap.set('n', '<C-PageDown>', 'G', vim.tbl_extend('force', kopts, { desc = 'Bottom of terminal scrollback' }))
  vim.keymap.set('n', '<C-kPageDown>', 'G', vim.tbl_extend('force', kopts, { desc = 'Bottom of terminal scrollback' }))
  vim.keymap.set('n', '<S-PageDown>', 'G', vim.tbl_extend('force', kopts, { desc = 'Bottom of terminal scrollback' }))
  vim.keymap.set('n', '<S-kPageDown>', 'G', vim.tbl_extend('force', kopts, { desc = 'Bottom of terminal scrollback' }))
  vim.keymap.set('n', '<C-Up>', 'gg', vim.tbl_extend('force', kopts, { desc = 'Top of terminal scrollback' }))
  vim.keymap.set('n', '<C-Down>', 'G', vim.tbl_extend('force', kopts, { desc = 'Bottom of terminal scrollback' }))
  vim.keymap.set('n', '<PageDown>', '<C-f>', vim.tbl_extend('force', kopts, { desc = 'Page down terminal scrollback' }))
  vim.keymap.set('n', '<kPageDown>', '<C-f>', vim.tbl_extend('force', kopts, { desc = 'Page down terminal scrollback' }))
  vim.keymap.set('n', '<PageUp>', '<C-b>', vim.tbl_extend('force', kopts, { desc = 'Page up terminal scrollback' }))
  vim.keymap.set('n', '<kPageUp>', '<C-b>', vim.tbl_extend('force', kopts, { desc = 'Page up terminal scrollback' }))
  local function open_agent_external_editor()
    local shortcut = label == 'CLAUDE' and '\x18\x05' or '\x07'
    vim.api.nvim_chan_send(vim.b.terminal_job_id, shortcut)
  end
  vim.keymap.set('n', '<M-e>', open_agent_external_editor, vim.tbl_extend('force', kopts, { desc = 'Open agent external editor' }))
  vim.keymap.set('n', '<Esc>e', open_agent_external_editor, vim.tbl_extend('force', kopts, { desc = 'Open agent external editor' }))
  vim.keymap.set('n', '<Home>', 'gg', vim.tbl_extend('force', kopts, { desc = 'Top of terminal scrollback' }))
  vim.keymap.set('n', '<End>', 'G', vim.tbl_extend('force', kopts, { desc = 'Bottom of terminal scrollback' }))
  vim.keymap.set('t', '<C-]>', function()
    vim.api.nvim_chan_send(vim.b.terminal_job_id, '\x1b')
  end, vim.tbl_extend('force', kopts, { desc = 'Send Escape to terminal' }))
  vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], kopts)
  vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], kopts)
  vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], kopts)
  vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], kopts)
end

function _G.agent_terminal_send_to_label(label, data)
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(bufnr) and vim.b[bufnr].agent_terminal_label == label then
      local job_id = vim.b[bufnr].terminal_job_id
      if job_id then
        vim.api.nvim_chan_send(job_id, data)
        vim.defer_fn(function()
          for _, winid in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_is_valid(winid) and vim.api.nvim_win_get_buf(winid) == bufnr then
              unlock_terminal_view(winid)
              vim.api.nvim_win_call(winid, function()
                if vim.api.nvim_get_mode().mode == 't' then
                  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-\\><C-n>G', true, false, true), 'n', false)
                else
                  vim.cmd 'normal! G'
                end
              end)
            end
          end
        end, 50)
        return true
      end
    end
  end
  return false
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

local agent_terminal_group = vim.api.nvim_create_augroup('CustomAgentTerminal', { clear = true })

vim.api.nvim_create_autocmd({ 'TermOpen', 'TermEnter', 'BufWinEnter' }, {
  group = agent_terminal_group,
  pattern = 'term://*',
  callback = function(args) set_terminal_keymaps(args.buf) end,
})

vim.api.nvim_create_autocmd('ModeChanged', {
  group = agent_terminal_group,
  callback = function()
    local winid = vim.api.nvim_get_current_win()
    set_terminal_chrome(vim.api.nvim_win_get_buf(winid))

    if should_lock_terminal_view() then
      lock_terminal_view(winid)
    else
      unlock_terminal_view(winid)
    end

    vim.cmd 'redrawstatus'
  end,
})

vim.api.nvim_create_autocmd({ 'WinScrolled', 'CursorMoved' }, {
  group = agent_terminal_group,
  callback = function()
    local winid = vim.api.nvim_get_current_win()
    local lock = terminal_scroll_locks[winid]
    if lock and not lock.restoring and is_terminal_scroll_mode() then
      lock.view = vim.fn.winsaveview()
    end
    enter_terminal_insert_at_bottom(winid)
  end,
})

vim.api.nvim_create_autocmd({ 'BufWipeout', 'TermClose' }, {
  group = agent_terminal_group,
  pattern = 'term://*',
  callback = function(args) unlock_terminal_buffer(args.buf) end,
})
