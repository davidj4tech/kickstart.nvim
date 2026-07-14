local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  { src = gh 'akinsho/toggleterm.nvim', version = vim.version.range '*' }, -- stable releases
}

require('toggleterm').setup {
  open_mapping = [[<c-\>]],
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

local function set_terminal_keymaps()
  local kopts = { buffer = 0 }
  vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], kopts)
  vim.keymap.set('t', 'jk', [[<C-\><C-n>]], kopts)
  vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], kopts)
  vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], kopts)
  vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], kopts)
  vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], kopts)
end

vim.api.nvim_create_autocmd('TermOpen', {
  pattern = 'term://*toggleterm#*',
  callback = set_terminal_keymaps,
})
