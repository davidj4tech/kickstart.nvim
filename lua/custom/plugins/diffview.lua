return {
  'sindrets/diffview.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewToggleFiles', 'DiffviewFocusFiles', 'DiffviewFileHistory' },
  keys = {
    { '<leader>gv', '<cmd>DiffviewOpen<cr>', desc = '[G]it diff[V]iew' },
    { '<leader>gh', '<cmd>DiffviewFileHistory<cr>', desc = '[G]it [H]istory (repo)' },
    { '<leader>gf', '<cmd>DiffviewFileHistory %<cr>', desc = '[G]it history of [F]ile' },
    { '<leader>gc', '<cmd>DiffviewClose<cr>', desc = '[G]it diffview [C]lose' },
  },
}
