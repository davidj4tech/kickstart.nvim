return {
  'mozanunal/sllm.nvim',
  dependencies = {
    'echasnovski/mini.notify', -- optional: gives you nicer looking notifications
    'echasnovski/mini.pick', -- optional: better UI for picking models/files
  },
  config = function()
    require('sllm').setup {
      -- You can drop custom settings in here later
      -- Leaving it empty just loads the default settings
    }
  end,
}
