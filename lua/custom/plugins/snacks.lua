-- folke/snacks.nvim — QoL primitives (notifier, input, terminal, bigfile). Also
-- the terminal/picker dependency claudecode.nvim + avante.nvim rely on, declared
-- here so its own opts win and it loads early.
return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  opts = {
    bigfile = { enabled = true },
    quickfile = { enabled = true },
    notifier = { enabled = true },
    input = { enabled = true },
    terminal = {},
  },
}
