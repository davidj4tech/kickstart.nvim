-- mozanunal/sllm.nvim — wraps Simon Willison's `llm` CLI. Owns <leader>ss
-- (bound in the telescope section of init.lua).
local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'nvim-mini/mini.notify', -- optional: nicer looking notifications
  gh 'nvim-mini/mini.pick', -- optional: better UI for picking models/files
  gh 'mozanunal/sllm.nvim',
}

require('sllm').setup {
  -- You can drop custom settings in here later
  -- Leaving it empty just loads the default settings
}
