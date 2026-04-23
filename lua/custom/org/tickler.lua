local M = {}

function M.review(paths)
  require('orgmode.api.agenda').agenda {
    header = 'Tickler review',
    org_agenda_files = { vim.fn.expand(paths.org_tickler) },
    span = 'month',
  }
end

function M.refile_current(paths)
  local api = require 'orgmode.api'
  local current_file = api.current()
  local source = current_file:get_closest_headline()

  if not source then
    vim.notify('No Org headline at cursor', vim.log.levels.WARN)
    return
  end

  local tickler_file = api.load(vim.fn.expand(paths.org_tickler))
  local destination = tickler_file.headlines[1] or tickler_file

  api.refile { source = source, destination = destination }:next(function()
    if destination.headlines then
      destination = destination:reload()
      local moved = destination.headlines[#destination.headlines]
      if moved then
        vim.cmd.edit(vim.fn.expand(paths.org_tickler))
        vim.fn.cursor { moved.position.start_line, 0 }
        return moved:set_scheduled()
      end
    end

    vim.notify('Refiled to tickler, but could not find moved headline for scheduling', vim.log.levels.WARN)
  end)
end

return M
