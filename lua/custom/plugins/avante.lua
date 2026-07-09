-- yetone/avante.nvim — Cursor-style agentic edits (sidebar diff-apply). Overlaps
-- claudecode (both do agentic edits); kept on a separate <leader>v (aVante) prefix.
--
-- Model: the LIBERATED Claude Opus 4.8 lane via the red5 litellm gateway (:4000).
-- Same Opus 4.8 backend as normal, opted-in by model name; litellm's liberator
-- callback auto-reroutes to Venice if Claude refuses (non-streaming calls). Needs
-- $LITELLM_MASTER_KEY in the environment (same key on every tailnet host).
--
-- `build = make` fetches avante's prebuilt Rust helper. Those libs are glibc
-- x86-64/aarch64 — they don't load under Termux (Android/bionic), so avante
-- self-disables there (p8a) via `enabled`, keeping the one shared fork uniform.
return {
  'yetone/avante.nvim',
  event = 'VeryLazy',
  version = false, -- track latest; avante's config API moves fast
  build = 'make',
  enabled = function()
    return vim.env.TERMUX_VERSION == nil and vim.fn.isdirectory '/data/data/com.termux' == 0
  end,
  opts = {
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
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    'nvim-treesitter/nvim-treesitter',
    'folke/snacks.nvim',
  },
}
