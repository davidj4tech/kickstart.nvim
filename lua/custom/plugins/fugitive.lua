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
local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'tpope/vim-fugitive' }

require('which-key').add { { '<leader>g', group = '[G]it (fugitive)' } }
vim.keymap.set('n', '<leader>gs', '<cmd>Git<cr>', { desc = '[G]it [S]tatus' })
vim.keymap.set('n', '<leader>gc', '<cmd>Git commit<cr>', { desc = '[G]it [C]ommit' })
vim.keymap.set('n', '<leader>gb', '<cmd>Git blame<cr>', { desc = '[G]it [B]lame' })
vim.keymap.set('n', '<leader>gd', '<cmd>Gdiffsplit<cr>', { desc = '[G]it [D]iff split' })
vim.keymap.set('n', '<leader>gl', '<cmd>Git log<cr>', { desc = '[G]it [L]og' })
vim.keymap.set('n', '<leader>gL', '<cmd>0Glog<cr>', { desc = '[G]it file [L]og (quickfix)' })
