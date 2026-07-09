-- olimorris/codecompanion.nvim — the second-model "critic" alongside claudecode.
-- A genuinely different vendor (OpenAI) for real second opinions, not a Claude echo.
--
-- Model: gpt-5-codex via the red5 litellm gateway (:4000), which bridges codex's
-- Responses-only API to chat/completions. One endpoint + one key (LITELLM_MASTER_KEY)
-- shared with avante's liberated lane. Swap the schema default to 'gpt-5.1' for the
-- plain chat model, or point at any litellm model_name (venice/*, hermes-4-405b, …).
return {
  'olimorris/codecompanion.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  opts = {
    adapters = {
      http = {
        codex = function()
          return require('codecompanion.adapters').extend('openai_compatible', {
            env = {
              url = 'http://red5:4000',
              api_key = 'LITELLM_MASTER_KEY',
            },
            schema = {
              model = { default = 'gpt-5-codex' },
            },
          })
        end,
      },
    },
    strategies = {
      chat = { adapter = 'codex' },
      inline = { adapter = 'codex' },
    },
  },
  keys = {
    { '<leader>cc', '<cmd>CodeCompanionChat Toggle<cr>', mode = { 'n', 'v' }, desc = 'CodeCompanion: chat' },
    { '<leader>ca', '<cmd>CodeCompanionActions<cr>', mode = { 'n', 'v' }, desc = 'CodeCompanion: actions' },
    { '<leader>ci', ':CodeCompanion ', mode = { 'n', 'v' }, desc = 'CodeCompanion: inline prompt' },
  },
}
