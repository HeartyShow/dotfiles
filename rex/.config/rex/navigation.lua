-- Like tmux, moving sideways into a column returns to the pane last used in that column.
local column_memory = {}

local function column(pane)
  return string.format("%.3f:%.3f", pane.rect[1], pane.rect[3])
end

local function leaves(node, out)
  if node.block_id then
    out[#out + 1] = node
  elseif node.split then
    leaves(node.split.before, out)
    leaves(node.split.after, out)
  end
  return out
end

local function neighbours(panes, from, direction)
  local function near(a, b) return math.abs(a - b) < 0.001 end
  local f = from.rect
  local found = {}
  for _, pane in ipairs(panes) do
    local r = pane.rect
    local touches, overlaps
    if direction == "left" then
      touches = near(r[1] + r[3], f[1])
    elseif direction == "right" then
      touches = near(r[1], f[1] + f[3])
    elseif direction == "up" then
      touches = near(r[2] + r[4], f[2])
    else
      touches = near(r[2], f[2] + f[4])
    end
    if direction == "left" or direction == "right" then
      overlaps = r[2] < f[2] + f[4] and r[2] + r[4] > f[2]
    else
      overlaps = r[1] < f[1] + f[3] and r[1] + r[3] > f[1]
    end
    if touches and overlaps then found[#found + 1] = pane end
  end
  return found
end

local function tiled_panes(session_id)
  local view = rex.call("session.view", { session_id = session_id })
  for _, w in ipairs(view and view.windows or {}) do
    if w.window_id == view.active_window_id then
      for _, layer in ipairs(w.layers or {}) do
        if layer.kind == "tiled" then
          local panes, focused = leaves(layer.layout, {}), nil
          for _, pane in ipairs(panes) do
            if pane.block_id == w.focused_block_id then focused = pane end
          end
          return panes, focused
        end
      end
    end
  end
  return {}, nil
end

local function focus(session_id, direction)
  local panes, from = tiled_panes(session_id)
  local target
  if from ~= nil then
    column_memory[column(from)] = from.block_id
    if direction == "left" or direction == "right" then
      for _, pane in ipairs(neighbours(panes, from, direction)) do
        if column_memory[column(pane)] == pane.block_id then target = pane end
      end
    end
  end
  if target ~= nil then
    rex.call("session.focus_block", { session_id = session_id, block_id = target.block_id })
  else
    rex.call("session.focus_direction", { session_id = session_id, direction = direction })
    local _, focused = tiled_panes(session_id)
    target = focused
  end
  if target ~= nil then column_memory[column(target)] = target.block_id end
end

local vim_names = { vim = true, nvim = true, view = true, vimdiff = true }

-- Same detection as paul-enz/vim-rex-navigator: its Neovim half handles the key and calls `rex focus` at the edge.
local function in_vim()
  local ok, proc = pcall(rex.block.call, "com.superlogical.terminal", "process")
  local fg = ok and proc and proc.foreground
  return fg ~= nil and (vim_names[fg.name] or vim_names[fg.argv0]) == true
end

-- Neovim calls this at its edge (instead of `rex focus`) so leaving it is remembered too.
rex.action{
  name = "focus_pane",
  title = "Focus Pane",
  args = { direction = "string" },
  run = function(ctx, args) return focus(ctx.session_id, args.direction) end,
}

for direction, key in pairs({ left = "ctrl+h", down = "ctrl+j", up = "ctrl+k", right = "ctrl+l" }) do
  rex.bind(key, function(ctx)
    if in_vim() then return false end
    focus(ctx.session_id, direction)
    return true
  end)
end
