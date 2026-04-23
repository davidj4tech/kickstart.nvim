# Custom Org Notes

The canonical workflow document for this system lives at:

- [productivity-system.org](/home/ryer/org/productivity-system.org:1)

This Neovim config mirrors that shared workflow rather than defining a separate one.

Relevant modules:

- [plugins/org.lua](/home/ryer/.config/nvim/lua/custom/plugins/org.lua:1)
  Plugin wiring, keymaps, and Orgmode integration.

- [org/paths.lua](/home/ryer/.config/nvim/lua/custom/org/paths.lua:1)
  Shared Org file paths.

- [org/capture.lua](/home/ryer/.config/nvim/lua/custom/org/capture.lua:1)
  Capture templates shared conceptually with Emacs.

- [org/roam.lua](/home/ryer/.config/nvim/lua/custom/org/roam.lua:1)
  org-roam templates and dailies.

- [org/dashboard.lua](/home/ryer/.config/nvim/lua/custom/org/dashboard.lua:1)
  Project dashboard generation.

- [org/tickler.lua](/home/ryer/.config/nvim/lua/custom/org/tickler.lua:1)
  Tickler review and refile helpers.

Useful Neovim entry points:

- `<leader>ot` tickler review
- `<leader>ok` send current heading to tickler
- `<leader>na` project dashboard
- `<leader>nj` today’s roam daily
- `<leader>nn`, `<leader>np`, `<leader>nP`, `<leader>nr` roam capture

If the workflow changes, update `~/org/productivity-system.org` first, then adjust this config to match.
