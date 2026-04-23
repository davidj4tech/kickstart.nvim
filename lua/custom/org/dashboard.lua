local M = {}

local function expand(path)
  return vim.fn.expand(path)
end

local function read_title_status_and_next_action(path)
  local lines = vim.fn.readfile(path)
  local title = vim.fn.fnamemodify(path, ':t:r')
  local status = 'unknown'
  local next_action = nil

  for _, line in ipairs(lines) do
    local file_title = line:match('^#%+TITLE:%s*(.+)$')
    if file_title then
      title = vim.trim(file_title)
    end

    local property_status = line:match('^:STATUS:%s*(.+)$')
    if property_status then
      status = vim.trim(property_status):lower()
    end

    if not next_action then
      local todo_state, headline_text = line:match('^%*+%s+(TODO|NEXT|WAITING)%s+(.+)$')
      if todo_state and headline_text then
        next_action = string.format('%s %s', todo_state, vim.trim(headline_text))
      end
    end
  end

  return title, status, next_action
end

local function relative_to_roam(path, paths)
  local roam_root = expand(paths.org_roam_dir) .. '/'
  return path:gsub('^' .. vim.pesc(roam_root), '')
end

function M.update(paths)
  local dashboard_path = expand(paths.org_roam_projects_index)
  local projects_dir = expand(paths.org_roam_projects_dir)
  local files = vim.fn.globpath(projects_dir, '*.org', false, true)
  local grouped = {
    active = {},
    waiting = {},
    paused = {},
    someday = {},
    done = {},
    unknown = {},
  }

  table.sort(files)

  for _, path in ipairs(files) do
    if path ~= dashboard_path then
      local title, status, next_action = read_title_status_and_next_action(path)
      local bucket = grouped[status] and status or 'unknown'
      local item = string.format('- [[file:%s][%s]]', relative_to_roam(path, paths), title)
      if next_action then
        item = string.format('%s :: %s', item, next_action)
      end
      table.insert(grouped[bucket], item)
    end
  end

  local lines = {
    '#+TITLE: Active Projects Dashboard',
    '#+filetags: :project:dashboard:',
    '',
    string.format('Updated: %s', os.date('%Y-%m-%d %H:%M')),
    '',
    '* Active',
  }

  vim.list_extend(lines, vim.tbl_isempty(grouped.active) and { '- None' } or grouped.active)
  vim.list_extend(lines, { '', '* Waiting' })
  vim.list_extend(lines, vim.tbl_isempty(grouped.waiting) and { '- None' } or grouped.waiting)
  vim.list_extend(lines, { '', '* Paused' })
  vim.list_extend(lines, vim.tbl_isempty(grouped.paused) and { '- None' } or grouped.paused)
  vim.list_extend(lines, { '', '* Someday' })
  vim.list_extend(lines, vim.tbl_isempty(grouped.someday) and { '- None' } or grouped.someday)
  vim.list_extend(lines, { '', '* Done' })
  vim.list_extend(lines, vim.tbl_isempty(grouped.done) and { '- None' } or grouped.done)
  vim.list_extend(lines, { '', '* Unsorted' })
  vim.list_extend(lines, vim.tbl_isempty(grouped.unknown) and { '- None' } or grouped.unknown)

  vim.fn.writefile(lines, dashboard_path)
  return dashboard_path
end

function M.ensure(paths)
  if vim.fn.filereadable(expand(paths.org_roam_projects_index)) == 0 then
    M.update(paths)
  end
end

return M
