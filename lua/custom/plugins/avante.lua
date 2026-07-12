-- yetone/avante.nvim — Cursor-style agentic edits (sidebar diff-apply). Overlaps
-- claudecode (both do agentic edits); kept on a separate <leader>v (aVante) prefix.
--
-- Model: the LIBERATED Claude Opus 4.8 lane via the red5 litellm gateway (:4000).
-- Same Opus 4.8 backend as normal, opted-in by model name; litellm's liberator
-- callback auto-reroutes to Venice if Claude refuses (non-streaming calls). Needs
-- $LITELLM_MASTER_KEY in the environment (same key on every tailnet host).
--
-- The `make` build fetches avante's prebuilt Rust helper. Those libs are glibc
-- x86-64/aarch64 — they don't load under Termux (Android/bionic), so avante
-- self-disables there (p8a), keeping the one shared fork uniform.
if vim.env.TERMUX_VERSION ~= nil or vim.fn.isdirectory '/data/data/com.termux' == 1 then return end

local function gh(repo) return 'https://github.com/' .. repo end

-- Build hook must be registered before vim.pack.add so a fresh install runs it.
vim.api.nvim_create_autocmd('PackChanged', {
  group = vim.api.nvim_create_augroup('custom-avante-build', { clear = true }),
  callback = function(ev)
    if ev.data.spec.name ~= 'avante.nvim' then return end
    if ev.data.kind ~= 'install' and ev.data.kind ~= 'update' then return end
    local result = vim.system({ 'make' }, { cwd = ev.data.path }):wait()
    if result.code ~= 0 then
      vim.notify(('avante.nvim build failed:\n%s'):format(result.stderr or result.stdout or ''), vim.log.levels.ERROR)
    end
  end,
})

vim.pack.add {
  gh 'nvim-lua/plenary.nvim',
  gh 'MunifTanjim/nui.nvim',
  gh 'folke/snacks.nvim', -- configured in snacks.lua
  gh 'yetone/avante.nvim',
}

require('avante').setup {
  provider = 'liberated',
  providers = {
    liberated = {
      __inherited_from = 'openai',
      endpoint = 'http://red5:4000/v1',
      model = 'claude-opus-4-8-liberated',
      api_key_name = 'LITELLM_MASTER_KEY',
    },
  },
  mappings = {
    ask = '<leader>va',
    edit = '<leader>ve',
    refresh = '<leader>vr',
    focus = '<leader>vf',
    toggle = {
      default = '<leader>vt',
      debug = '<leader>vd',
      hint = '<leader>vh',
      suggestion = '<leader>vs',
    },
  },
}
