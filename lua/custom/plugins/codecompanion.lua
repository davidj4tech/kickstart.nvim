-- olimorris/codecompanion.nvim — the second-model "critic" alongside claudecode.
-- A genuinely different vendor (OpenAI) for real second opinions, not a Claude echo.
--
-- Driven as SUBSCRIPTION Codex over ACP (Agent Client Protocol), not the metered
-- API — so it rides your ChatGPT plan, zero per-token cost. codecompanion's preset
-- `codex` ACP adapter launches the `codex-acp` bridge; auth_method=chatgpt uses the
-- `codex` CLI's OAuth login (auth_mode: chatgpt).
--
-- Per-host prereqs (adapter simply won't launch where absent — no error until used):
--   • codex CLI, logged in via ChatGPT   (`codex login`)
--   • codex-acp on PATH   (`npm i -g @agentclientprotocol/codex-acp`)
local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'nvim-lua/plenary.nvim',
  gh 'olimorris/codecompanion.nvim',
}

require('codecompanion').setup {
  adapters = {
    acp = {
      codex = function()
        return require('codecompanion.adapters').extend('codex', {
          defaults = {
            auth_method = 'chatgpt', -- ride the ChatGPT subscription, not an API key
          },
        })
      end,
    },
  },
  strategies = {
    chat = { adapter = 'codex' },
    inline = { adapter = 'codex' },
  },
}

vim.keymap.set({ 'n', 'v' }, '<leader>cc', '<cmd>CodeCompanionChat Toggle<cr>', { desc = 'CodeCompanion: chat (Codex)' })
vim.keymap.set({ 'n', 'v' }, '<leader>ca', '<cmd>CodeCompanionActions<cr>', { desc = 'CodeCompanion: actions' })
vim.keymap.set({ 'n', 'v' }, '<leader>ci', ':CodeCompanion ', { desc = 'CodeCompanion: inline prompt' })
