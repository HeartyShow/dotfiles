rex.mode("repeat", { exclusive = true })
rex.bind("ctrl+space>ctrl+r", "client.mode.enter", { name = "repeat" })
rex.bind("repeat/enter", "client.mode.exit")
rex.bind("repeat/escape", "client.mode.exit")

rex.bind("ctrl+space>ctrl+space", "pane.send_key", { key = "ctrl+space" })
rex.bind("ctrl+space>r", "client.config.reload")
rex.bind("ctrl+space>b", "pane.split", { direction = "right" })
rex.bind("ctrl+space>v", "pane.split", { direction = "down" })
for key, direction in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  rex.bind("ctrl+space>" .. key, "pane.resize", { amount = 5, direction = direction })
  rex.bind("repeat/" .. key, "pane.resize", { amount = 5, direction = direction })
end
rex.bind("ctrl+z", "pane.zoom")
rex.bind("ctrl+space>x", "pane.close")
rex.bind("ctrl+space>shift+x", "client.tab.close")
rex.bind("ctrl+space>ctrl+h", "client.tab.previous")
rex.bind("repeat/ctrl+h", "client.tab.previous")
rex.bind("ctrl+space>ctrl+l", "client.tab.next")
rex.bind("repeat/ctrl+l", "client.tab.next")

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

local terminal = "com.superlogical.terminal"
local shell = "com.superlogical.terminal.shell"

-- Scripts can pass `cwd` and space-separated extra `args` for the popup command.
local function popup_action(name, title, command, width, height)
  rex.action{
    name = name,
    title = title,
    args = { cwd = "string?", args = "string?" },
    run = function(ctx, args)
      local cwd = args.cwd
      if cwd == nil or cwd == "" then
        local info = rex.block.call(terminal, "process", {})
        cwd = info and info.foreground and info.foreground.cwd
      end
      local full = {}
      for _, word in ipairs(command) do table.insert(full, word) end
      for word in (args.args or ""):gmatch("%S+") do table.insert(full, word) end
      return rex.session.new_layer{
        bounds = { (1 - width) / 2, (1 - height) / 2, width, height },
        focus = true,
        layout = rex.layout.block{
          flavor = shell,
          label = title,
          options = { command = full, cwd = cwd },
        },
      }
    end,
  }
end

-- Actions run from scripts change server state only; the app has to be told to follow.
local function show(session_id, window_id)
  local result = rex.call("client.list")
  for _, client in ipairs(result and result.clients or {}) do
    if client.info and client.info.kind == "app" then
      return rex.call("client.perform", {
        client_id = client.client_id,
        action = "session.select",
        args = { session_id = session_id, window_id = window_id },
      })
    end
  end
end

local function session_id_named(name)
  local result = rex.call("session.list")
  for _, session in ipairs(result and result.sessions or {}) do
    if session.label == name then
      return session.session_id
    end
  end
end

rex.action{
  name = "open_session",
  title = "Open Session",
  args = { name = "string", path = "string" },
  run = function(ctx, args)
    local id = session_id_named(args.name)
    if id == nil and args.path ~= "" then
      local created, err = rex.call("session.create", {
        label = args.name,
        initial_windows = { { layout = rex.layout.block{ flavor = shell, options = { cwd = args.path } } } },
      })
      if err ~= nil then error(err, 0) end
      id = created.session_id
    end
    if id ~= nil then
      show(id)
    end
  end,
}

rex.action{
  name = "open_worktree",
  title = "Open Worktree",
  args = { path = "string", background = "boolean" },
  run = function(ctx, args)
    local name = args.path:match("([^/]+)/?$")
    local view = rex.session.view{}
    for _, window in ipairs(view and view.windows or {}) do
      if window.label == name then
        if args.background then return end
        rex.session.focus_window{ window_id = window.window_id }
        return show(view.session_id, window.window_id)
      end
    end
    local function block(command)
      return rex.layout.block{ flavor = shell, options = { cwd = args.path, command = command } }
    end
    local created = rex.session.new_window{
      window_label = name,
      focus = not args.background,
      layout = rex.layout.horizontal(0.4,
        rex.layout.vertical(0.75, block({ "nvim" }), block(nil)),
        block({ "sh", "-c", "OPENCODE_DISABLE_TERMINAL_TITLE=1 opencode" })),
    }
    if not args.background then
      return show(view.session_id, created.window_id)
    end
  end,
}

popup_action("popup_sessions", "Session Picker", { "sh", os.getenv("HOME") .. "/.config/rex/scripts/sessions.sh", "pick" }, 0.8, 0.7)
popup_action("popup_worktrees", "Worktree Picker", { "sh", os.getenv("HOME") .. "/.config/rex/scripts/worktrees.sh", "pick" }, 0.8, 0.7)
popup_action("popup_gh_dash", "GitHub Dashboard (gh-dash)", { "gh-dash" }, 0.95, 0.9)
popup_action("popup_tuicr", "Review Worktree Changes (tuicr)", { "tuicr" }, 0.95, 0.9)

-- The assistant popup toggles: closing it only ends the TUI, the chat server keeps running.
local assistant = "Assistant (OpenCode)"
rex.action{
  name = "popup_assistant",
  title = assistant,
  run = function()
    local view = rex.session.view{}
    for _, window in ipairs(view and view.windows or {}) do
      for _, layer in ipairs(window.layers or {}) do
        for _, block in ipairs(layer.blocks or {}) do
          if block.label == assistant then
            return rex.session.close_layer{ session_id = view.session_id, layer_id = layer.layer_id }
          end
        end
      end
    end
    return rex.session.new_layer{
      bounds = { 0.025, 0.05, 0.95, 0.9 },
      focus = true,
      layout = rex.layout.block{
        flavor = shell,
        label = assistant,
        options = { command = { "sh", os.getenv("HOME") .. "/.config/rex/scripts/assistant.sh" } },
      },
    }
  end,
}

rex.bind("ctrl+space>f", "popup_sessions")
rex.bind("ctrl+space>w", "popup_worktrees")
rex.bind("ctrl+space>g", "popup_gh_dash")
rex.bind("ctrl+space>t", "popup_tuicr")
rex.bind("ctrl+space>a", "popup_assistant")
