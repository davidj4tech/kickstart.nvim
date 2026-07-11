-- Per-buffer settings for org files. Loaded after orgmode's own ftplugin.
--
-- NOTE: spell is handled globally by the `kickstart-spell` autocmd in init.lua.
-- NOTE: indentation (shiftwidth/tabstop/textwidth) is intentionally left alone
-- here -- orgmode manages its own (virtual) indentation, and overriding it
-- fights the plugin.

-- Soft wrapping for prose
vim.opt_local.wrap = true          -- wrap long lines on screen
vim.opt_local.linebreak = true     -- break at word boundaries, not mid-word
vim.opt_local.breakindent = true   -- wrapped lines keep the paragraph's indent
vim.opt_local.showbreak = '↳ '     -- marker on continuation lines

-- Move by VISUAL line so j/k don't leap over a whole wrapped paragraph
vim.keymap.set({ 'n', 'x' }, 'j', 'gj', { buffer = true })
vim.keymap.set({ 'n', 'x' }, 'k', 'gk', { buffer = true })
vim.keymap.set({ 'n', 'x' }, '0', 'g0', { buffer = true })
vim.keymap.set({ 'n', 'x' }, '$', 'g$', { buffer = true })

-- Emphasis markers (*bold* /italic/ etc, enabled via org_hide_emphasis_markers):
-- concealed in normal mode (rendered look), revealed while editing in insert.
vim.opt_local.conceallevel = 2
vim.opt_local.concealcursor = 'nc'   -- conceal the cursor line too in normal/command...
                                     -- ...but not in insert, so the line you edit shows markers
local grp = vim.api.nvim_create_augroup('org-emphasis-conceal-' .. vim.api.nvim_get_current_buf(), { clear = true })
vim.api.nvim_create_autocmd('InsertEnter', {
  group = grp,
  buffer = 0,
  desc = 'Reveal org emphasis markers while editing',
  callback = function() vim.opt_local.conceallevel = 0 end,
})
vim.api.nvim_create_autocmd('InsertLeave', {
  group = grp,
  buffer = 0,
  desc = 'Re-conceal org emphasis markers after editing',
  callback = function() vim.opt_local.conceallevel = 2 end,
})
