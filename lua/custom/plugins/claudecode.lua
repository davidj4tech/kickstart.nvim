-- coder/claudecode.nvim — Claude Code as an nvim-native IDE (its WebSocket/MCP
-- protocol, same one the VS Code / JetBrains extensions speak). Complements a
-- terminal `claude`: @-mention files, send visual selections, review edits as
-- native nvim diffs. Distinct from sllm (that wraps the `llm` CLI).
local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'folke/snacks.nvim', -- configured in snacks.lua
  gh 'coder/claudecode.nvim',
}

require('claudecode').setup {}

require('which-key').add { { '<leader>a', group = 'AI / Claude Code' } }
vim.keymap.set('n', '<leader>ac', '<cmd>ClaudeCode<cr>', { desc = 'Toggle Claude' })
vim.keymap.set('n', '<leader>af', '<cmd>ClaudeCodeFocus<cr>', { desc = 'Focus Claude' })
vim.keymap.set('n', '<leader>ar', '<cmd>ClaudeCode --resume<cr>', { desc = 'Resume Claude' })
vim.keymap.set('n', '<leader>aC', '<cmd>ClaudeCode --continue<cr>', { desc = 'Continue Claude' })
vim.keymap.set('n', '<leader>ab', '<cmd>ClaudeCodeAdd %<cr>', { desc = 'Add current buffer to context' })
vim.keymap.set('v', '<leader>as', '<cmd>ClaudeCodeSend<cr>', { desc = 'Send selection to Claude' })
vim.keymap.set('n', '<leader>aa', '<cmd>ClaudeCodeDiffAccept<cr>', { desc = 'Accept Claude diff' })
vim.keymap.set('n', '<leader>ad', '<cmd>ClaudeCodeDiffDeny<cr>', { desc = 'Deny Claude diff' })
