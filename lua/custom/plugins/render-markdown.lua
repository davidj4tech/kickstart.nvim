-- In-buffer markdown rendering (headings, code blocks, checkboxes, callouts).
-- https://github.com/MeanderingProgrammer/render-markdown.nvim
-- Icons come from mini.icons' nvim-web-devicons mock (init.lua section 4).
local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'MeanderingProgrammer/render-markdown.nvim' }

---@module 'render-markdown'
---@type render.md.UserConfig
require('render-markdown').setup {
  -- Attach beyond plain markdown (was the lazy `ft` list).
  file_types = { 'markdown', 'quarto', 'gitcommit' },

  -- Rendered in normal/command mode; raw markup in insert & visual so you
  -- edit the real syntax. Pairs with anti_conceal below.
  render_modes = { 'n', 'c' },
  anti_conceal = { enabled = true }, -- reveal raw markup on the cursor line

  heading = {
    width = 'full',
    position = 'inline',
  },
  code = {
    style = 'full',
    width = 'block',
    left_pad = 2,
    right_pad = 2,
  },
  checkbox = {
    checked = { icon = '󰄲 ' },
    unchecked = { icon = '󰄱 ' },
  },
}
