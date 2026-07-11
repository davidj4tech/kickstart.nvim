-- Per-buffer settings for markdown. Loaded automatically for any md buffer.
--
-- NOTE: spell is intentionally NOT set here -- it's handled globally by the
-- `kickstart-spell` FileType autocmd in init.lua, which also sets spelllang
-- to en_au and silent!-wraps setlocal to avoid the E756 prompt.
-- NOTE: conceallevel is intentionally NOT set here -- render-markdown.nvim
-- manages it (flips to 3 while rendering, restores your default otherwise).

-- Soft wrapping for prose
vim.opt_local.wrap = true          -- wrap long lines on screen
vim.opt_local.linebreak = true     -- break at word boundaries, not mid-word
vim.opt_local.breakindent = true   -- wrapped lines keep the paragraph's indent
vim.opt_local.showbreak = '↳ '     -- marker on continuation lines
vim.opt_local.textwidth = 0        -- soft wrap only; never insert hard newlines

-- Move by VISUAL line so j/k don't leap over a whole wrapped paragraph
vim.keymap.set({ 'n', 'x' }, 'j', 'gj', { buffer = true })
vim.keymap.set({ 'n', 'x' }, 'k', 'gk', { buffer = true })
vim.keymap.set({ 'n', 'x' }, '0', 'g0', { buffer = true })
vim.keymap.set({ 'n', 'x' }, '$', 'g$', { buffer = true })

-- List-aware formatting without auto hard-wrapping text
vim.opt_local.formatoptions:append 'n'   -- recognize numbered/bulleted lists
vim.opt_local.formatoptions:remove 't'   -- no auto hard-wrap of prose
vim.opt_local.formatoptions:remove 'c'   -- no auto-wrap in comments

-- 2-space indent is the markdown norm (nested lists render predictably)
vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.expandtab = true
