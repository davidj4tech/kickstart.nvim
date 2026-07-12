-- stevearc/overseer.nvim — task runner. The verify half of a propose→verify loop:
-- run tests / build / lint as tracked tasks and feed failures back to the agent.
-- Keys under <leader>r (run) — clear of org(<leader>o) and toggleterm(<leader>t).
local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'stevearc/overseer.nvim' }

require('overseer').setup {}

vim.keymap.set('n', '<leader>rr', '<cmd>OverseerRun<cr>', { desc = 'Overseer: run task' })
vim.keymap.set('n', '<leader>rt', '<cmd>OverseerToggle<cr>', { desc = 'Overseer: toggle panel' })
vim.keymap.set('n', '<leader>rc', '<cmd>OverseerRunCmd<cr>', { desc = 'Overseer: run shell cmd' })
