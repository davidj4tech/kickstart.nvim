local paths = require 'custom.org.paths'
local capture = require 'custom.org.capture'
local roam_config = require 'custom.org.roam'
local dashboard = require 'custom.org.dashboard'
local tickler = require 'custom.org.tickler'

local function gh(repo) return 'https://github.com/' .. repo end

-- [[ denote.nvim ]] — g:denote must be set before the plugin loads.
vim.fn.mkdir(vim.fn.expand(paths.denote_dir), 'p')
vim.g.denote = {
  filetype = 'org',
  directory = paths.denote_dir,
  prompts = { 'title', 'keywords' },
  integrations = {
    oil = true,
    telescope = {
      enabled = true,
    },
  },
}

vim.pack.add {
  gh 'cvigilv/denote.nvim',
  gh 'stevearc/oil.nvim',
  gh 'nvim-orgmode/orgmode',
  gh 'nvim-orgmode/telescope-orgmode.nvim',
  gh 'akinsho/org-bullets.nvim',
  gh 'chipsenkbeil/org-roam.nvim',
}

-- [[ oil.nvim ]] — buffer-as-filesystem explorer; owns <leader>e (wins over
-- nvim-tree's earlier binding, same as under lazy).
require('oil').setup {
  default_file_explorer = true,
  delete_to_trash = true,
  skip_confirm_for_simple_edits = true,
  view_options = {
    show_hidden = true,
  },
}
vim.keymap.set('n', '-', '<cmd>Oil<CR>', { desc = 'Open parent directory' })
vim.keymap.set('n', '<leader>e', '<cmd>Oil<CR>', { desc = 'Open file [E]xplorer' })

-- [[ orgmode + org-roam ]]
roam_config.ensure_dirs(paths)
dashboard.ensure(paths)
local function capture_roam_template(roam, key, templates)
  return function()
    roam.api.capture_node { templates = { [key] = templates[key] } }
  end
end

require('orgmode').setup {
  org_agenda_files = { paths.org_files },
  org_default_notes_file = paths.org_inbox,
  -- Conceal emphasis markers (*bold* /italic/ etc). after/ftplugin/org.lua
  -- reveals them again while in insert mode.
  org_hide_emphasis_markers = true,
  org_capture_templates = capture.templates(paths),
  org_agenda_custom_commands = {
    k = {
      description = 'Tickler review',
      types = {
        {
          type = 'agenda',
          org_agenda_overriding_header = 'Tickler review',
          org_agenda_span = 'month',
          org_agenda_files = { paths.org_tickler },
        },
      },
    },
  },
  hyperlinks = {
    sources = {
      require('denote.extensions.orgmode'):new {
        files = paths.denote_dir,
      },
    },
  },
}

require('org-bullets').setup()

local roam = require 'org-roam'
local roam_templates = roam_config.templates()

roam.setup {
  directory = paths.org_roam_dir,
  org_files = {
    paths.org_files,
  },
  templates = roam_templates,
  bindings = {
    prefix = '<Leader>n',
  },
  extensions = {
    dailies = roam_config.dailies(),
  },
}

vim.lsp.enable 'org'

vim.api.nvim_create_user_command('RoamProjectDashboard', function()
  vim.cmd.edit(dashboard.update(paths))
end, { desc = 'Regenerate and open the org-roam project dashboard' })

local ok, telescope = pcall(require, 'telescope')
if ok then
  pcall(telescope.load_extension, 'orgmode')
  pcall(telescope.load_extension, 'denote')
end

require('which-key').add {
  { '<leader>o', group = '[O]rg' },
  { '<leader>n', group = '[N]otes / Org-roam' },
}

vim.keymap.set('n', '<leader>oh', '<cmd>Telescope orgmode search_headings<CR>', { desc = '[O]rg search [H]eadings' })
vim.keymap.set('n', '<leader>or', '<cmd>Telescope orgmode refile_heading<CR>', { desc = '[O]rg [R]efile heading' })
vim.keymap.set('n', '<leader>ok', function() tickler.refile_current(paths) end, { desc = '[O]rg send to tic[k]ler' })
vim.keymap.set('n', '<leader>ot', function() tickler.review(paths) end, { desc = '[O]rg [T]ickler review' })
vim.keymap.set('n', '<leader>od', '<cmd>Telescope denote search<CR>', { desc = '[O]rg [D]enote search' })
vim.keymap.set('n', '<leader>oi', '<cmd>Telescope denote insert-link<CR>', { desc = '[O]rg denote [I]nsert link' })

vim.keymap.set('n', '<leader>nj', function() roam.ext.dailies.capture_today() end, { desc = '[N]ew roam [J]ournal entry' })
vim.keymap.set('n', '<leader>na', '<cmd>RoamProjectDashboard<CR>', { desc = '[N]otes [A]ctive project dashboard' })
vim.keymap.set('n', '<leader>nn', capture_roam_template(roam, 'd', roam_templates), { desc = '[N]ew roam [N]ote' })
vim.keymap.set('n', '<leader>np', capture_roam_template(roam, 'p', roam_templates), { desc = '[N]ew [P]erson note' })
vim.keymap.set('n', '<leader>nP', capture_roam_template(roam, 'j', roam_templates), { desc = '[N]ew [P]roject note' })
vim.keymap.set('n', '<leader>nr', capture_roam_template(roam, 'r', roam_templates), { desc = '[N]ew [R]eference note' })
