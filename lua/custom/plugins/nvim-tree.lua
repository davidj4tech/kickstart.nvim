-- nvim-tree.lua: file explorer side panel.
--
-- Two reasons we keep this in the kickstart fork rather than letting the
-- treemux tmux plugin install its own bundled copy:
--   1) Same nvim-tree is available when editing in a regular nvim
--      session (e.g. `:NvimTreeToggle`), not just inside the treemux
--      side pane.
--   2) Plugin updates / lockfile pinning go through the same vim.pack
--      path as everything else.
--
-- NOTE: <leader>e here is later rebound to Oil by org.lua (loads after this
-- file alphabetically) — same winner as under lazy. Use :NvimTreeToggle or
-- treemux's prefix-Tab pane (see ~/.tmux.conf.local).
local function gh(repo) return 'https://github.com/' .. repo end

-- nvim-tree wants these set before .setup() to avoid hijacked-by-netrw
-- races with file:// arg URIs.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true

-- Icons come from mini.icons' nvim-web-devicons mock (init.lua section 4).
vim.pack.add {
  { src = gh 'nvim-tree/nvim-tree.lua', version = vim.version.range '*' }, -- stable releases
}

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

vim.keymap.set('n', '<leader>e', '<cmd>NvimTreeToggle<cr>', { desc = 'Toggle file [E]xplorer' })
vim.keymap.set('n', '<leader>E', '<cmd>NvimTreeFindFile<cr>', { desc = 'Reveal current file in [E]xplorer' })
