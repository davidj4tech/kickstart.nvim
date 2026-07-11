-- In-buffer markdown rendering (headings, code blocks, checkboxes, callouts).
-- https://github.com/MeanderingProgrammer/render-markdown.nvim
return {
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-tree/nvim-web-devicons',
  },
  ft = { 'markdown', 'quarto', 'gitcommit' },
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {
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
  },
}
