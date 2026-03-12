local M = {}

local harpoon = require("harpoon")

local function normalize(path)
  return vim.fn.fnamemodify(path, ":p")
end

local function current_index()
  local list = harpoon:list()
  local current = normalize(vim.api.nvim_buf_get_name(0))

  for i, item in ipairs(list.items) do
    if normalize(item.value) == current then
      return i
    end
  end

  return nil
end

function M.prev_wrap()
  local list = harpoon:list()
  local count = #list.items
  if count == 0 then return end

  local idx = current_index()

  if not idx then
    list:select(count)
    return
  end

  if idx == 1 then
    list:select(count)
  else
    list:select(idx - 1)
  end
end

function M.next_wrap()
  local list = harpoon:list()
  local count = #list.items
  if count == 0 then return end

  local idx = current_index()

  if not idx then
    list:select(1)
    return
  end

  if idx == count then
    list:select(1)
  else
    list:select(idx + 1)
  end
end

return M
