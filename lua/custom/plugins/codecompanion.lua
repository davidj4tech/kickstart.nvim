-- olimorris/codecompanion.nvim — multi-provider chat/inline agent. Runs as a
-- second-model critic alongside claudecode: a side buffer for review / second
-- opinions. Defaults to the Anthropic adapter (reads $ANTHROPIC_API_KEY); swap
-- the adapter to 'ollama' for a local model. Keys under <leader>c (chat).
return {
  'olimorris/codecompanion.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  opts = {
    strategies = {
      chat = { adapter = 'anthropic' },
      inline = { adapter = 'anthropic' },
    },
  },
  keys = {
    { '<leader>cc', '<cmd>CodeCompanionChat Toggle<cr>', mode = { 'n', 'v' }, desc = 'CodeCompanion: chat' },
    { '<leader>ca', '<cmd>CodeCompanionActions<cr>', mode = { 'n', 'v' }, desc = 'CodeCompanion: actions' },
    { '<leader>ci', ':CodeCompanion ', mode = { 'n', 'v' }, desc = 'CodeCompanion: inline prompt' },
  },
}
