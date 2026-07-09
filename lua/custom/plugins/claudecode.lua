-- coder/claudecode.nvim — Claude Code as an nvim-native IDE (its WebSocket/MCP
-- protocol, same one the VS Code / JetBrains extensions speak). Complements a
-- terminal `claude`: @-mention files, send visual selections, review edits as
-- native nvim diffs. Distinct from sllm (that wraps the `llm` CLI).
return {
  'coder/claudecode.nvim',
  dependencies = { 'folke/snacks.nvim' },
  config = true,
  keys = {
    { '<leader>a', nil, desc = 'AI / Claude Code' },
    { '<leader>ac', '<cmd>ClaudeCode<cr>', desc = 'Toggle Claude' },
    { '<leader>af', '<cmd>ClaudeCodeFocus<cr>', desc = 'Focus Claude' },
    { '<leader>ar', '<cmd>ClaudeCode --resume<cr>', desc = 'Resume Claude' },
    { '<leader>aC', '<cmd>ClaudeCode --continue<cr>', desc = 'Continue Claude' },
    { '<leader>ab', '<cmd>ClaudeCodeAdd %<cr>', desc = 'Add current buffer to context' },
    { '<leader>as', '<cmd>ClaudeCodeSend<cr>', mode = 'v', desc = 'Send selection to Claude' },
    { '<leader>aa', '<cmd>ClaudeCodeDiffAccept<cr>', desc = 'Accept Claude diff' },
    { '<leader>ad', '<cmd>ClaudeCodeDiffDeny<cr>', desc = 'Deny Claude diff' },
  },
}
