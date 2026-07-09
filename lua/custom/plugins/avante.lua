-- yetone/avante.nvim — Cursor-style agentic edits (sidebar diff-apply). Overlaps
-- claudecode (both do agentic edits); kept deliberately on a separate <leader>v
-- (aVante) prefix so the two don't fight over <leader>a. Pointed at Claude via
-- the Anthropic API ($ANTHROPIC_API_KEY); model is configurable below.
-- `build = make` fetches avante's prebuilt Rust helper (no source compile).
return {
  'yetone/avante.nvim',
  event = 'VeryLazy',
  version = false, -- track latest; avante's config API moves fast
  build = 'make',
  opts = {
    provider = 'claude',
    providers = {
      claude = {
        endpoint = 'https://api.anthropic.com',
        model = 'claude-sonnet-5',
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
