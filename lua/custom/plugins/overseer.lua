-- stevearc/overseer.nvim — task runner. The verify half of a propose→verify loop:
-- run tests / build / lint as tracked tasks and feed failures back to the agent.
-- Keys under <leader>r (run) — clear of org(<leader>o) and toggleterm(<leader>t).
return {
  'stevearc/overseer.nvim',
  cmd = { 'OverseerRun', 'OverseerToggle', 'OverseerRunCmd' },
  opts = {},
  keys = {
    { '<leader>rr', '<cmd>OverseerRun<cr>', desc = 'Overseer: run task' },
    { '<leader>rt', '<cmd>OverseerToggle<cr>', desc = 'Overseer: toggle panel' },
    { '<leader>rc', '<cmd>OverseerRunCmd<cr>', desc = 'Overseer: run shell cmd' },
  },
}
