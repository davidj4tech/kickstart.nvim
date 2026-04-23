return {
  'akinsho/toggleterm.nvim',
  version = '*',
  keys = {
    { [[<C-\>]], mode = { 'n', 't' }, desc = 'Toggle terminal' },
    { '<leader>tt', '<cmd>ToggleTermToggleAll<cr>', desc = '[T]erminal [T]oggle all' },
    { '<leader>tf', '<cmd>ToggleTerm direction=float<cr>', desc = '[T]erminal [F]loat' },
    { '<leader>th', '<cmd>ToggleTerm direction=horizontal<cr>', desc = '[T]erminal [H]orizontal' },
    { '<leader>tv', '<cmd>ToggleTerm direction=vertical size=80<cr>', desc = '[T]erminal [V]ertical' },
  },
  opts = {
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
  },
  config = function(_, opts)
    require('toggleterm').setup(opts)

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
  end,
}
