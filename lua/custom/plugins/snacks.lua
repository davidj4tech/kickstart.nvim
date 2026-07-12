-- folke/snacks.nvim — QoL primitives (notifier, input, terminal, bigfile). Also
-- the terminal/picker dependency claudecode.nvim + avante.nvim rely on; those
-- files vim.pack.add it too (idempotent) but setup happens once, here.
local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'folke/snacks.nvim' }

require('snacks').setup {
  bigfile = { enabled = true },
  quickfile = { enabled = true },
  notifier = { enabled = true },
  input = { enabled = true },
  terminal = {},
}
