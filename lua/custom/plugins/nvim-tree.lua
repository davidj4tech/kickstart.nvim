-- nvim-tree.lua: file explorer side panel.
--
-- Two reasons we keep this in the kickstart fork rather than letting the
-- treemux tmux plugin install its own bundled copy:
--   1) Same nvim-tree is available when editing in a regular nvim
--      session (e.g. `:NvimTreeToggle`), not just inside the treemux
--      side pane.
--   2) Plugin updates / lockfile pinning go through the same lazy.nvim
--      path as everything else.
--
-- Default key: <leader>e toggles. The treemux tmux plugin
-- (kiyoon/treemux) opens its own pane — see ~/.tmux.conf.local for
-- the prefix-Tab binding.

return {
  'nvim-tree/nvim-tree.lua',
  version = '*',
  lazy = false,
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  keys = {
    { '<leader>e', '<cmd>NvimTreeToggle<cr>', desc = 'Toggle file [E]xplorer' },
    { '<leader>E', '<cmd>NvimTreeFindFile<cr>', desc = 'Reveal current file in [E]xplorer' },
  },
  config = function()
    -- nvim-tree wants these set before .setup() to avoid hijacked-by-
    -- netrw races with file:// arg URIs.
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
    vim.opt.termguicolors = true

    require('nvim-tree').setup {
      hijack_cursor = true,
      sync_root_with_cwd = true,
      respect_buf_cwd = true,
      update_focused_file = { enable = true, update_root = false },
      view = { width = 32, side = 'left' },
      renderer = {
        group_empty = true,
        highlight_git = true,
        icons = { show = { folder_arrow = true } },
      },
      filters = { dotfiles = false, custom = { '^.git$' } },
      git = { enable = true, ignore = false },
      actions = { open_file = { quit_on_open = false } },
    }
  end,
}
