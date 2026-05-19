-- vim-fugitive: in-editor git porcelain.
--
-- Complements gitsigns (which handles hunk-level staging/diff in the
-- buffer gutter via <leader>h*). Fugitive covers the repo-level
-- workflow: status buffer, commits, log, blame, three-way diff.
--
-- Quick reference:
--   <leader>gs  :Git           status buffer (s/u to stage, cc to commit, = to expand diff)
--   <leader>gc  :Git commit    new commit
--   <leader>gb  :Git blame     blame current file
--   <leader>gd  :Gdiffsplit    diff working copy vs index
--   <leader>gl  :Git log       log in pager
--   <leader>gL  :0Glog         file history in quickfix

return {
  {
    'tpope/vim-fugitive',
    cmd = { 'Git', 'G', 'Gdiffsplit', 'Gread', 'Gwrite', 'Ggrep', 'GMove', 'GRename', 'GDelete', 'GRemove', 'GBrowse', 'Gedit', 'Gsplit', 'Gvsplit', 'Gtabedit', 'Gclog', 'Glgrep' },
    keys = {
      { '<leader>gs', '<cmd>Git<cr>',          desc = '[G]it [S]tatus' },
      { '<leader>gc', '<cmd>Git commit<cr>',   desc = '[G]it [C]ommit' },
      { '<leader>gb', '<cmd>Git blame<cr>',    desc = '[G]it [B]lame' },
      { '<leader>gd', '<cmd>Gdiffsplit<cr>',   desc = '[G]it [D]iff split' },
      { '<leader>gl', '<cmd>Git log<cr>',      desc = '[G]it [L]og' },
      { '<leader>gL', '<cmd>0Glog<cr>',        desc = '[G]it file [L]og (quickfix)' },
    },
  },
  {
    'folke/which-key.nvim',
    optional = true,
    opts = function(_, opts)
      opts.spec = opts.spec or {}
      table.insert(opts.spec, { '<leader>g', group = '[G]it (fugitive)' })
    end,
  },
}
