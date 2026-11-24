local M = {}

M.home = os.getenv("HOME")
M.terminal = "com.superlogical.terminal"
M.shell = "com.superlogical.terminal.shell"

function M.tilde(path)
  return (path:gsub("^" .. M.home:gsub("%p", "%%%0"), "~"))
end

function M.basename(path)
  return path:match("([^/]+)/?$")
end

-- The server runs with launchd's bare PATH, which lacks Nix tools such as zoxide.
local path = M.home .. "/.nix-profile/bin:/run/current-system/sw/bin:/usr/bin:/bin:/usr/sbin:/sbin"

function M.lines(command, cwd)
  local result = rex.exec(command, { cwd = cwd, env = { PATH = path } })
  local out = {}
  if result and result.code == 0 then
    for line in result.stdout:gmatch("[^\n]+") do out[#out + 1] = line end
  end
  return out
end

function M.foreground_cwd(block_id)
  local info = rex.block.call(M.terminal, "process", { block_id = block_id })
  return info and info.foreground and info.foreground.cwd
end

function M.windows(session_id)
  local view = rex.call("session.view", { session_id = session_id })
  return view and view.windows or {}, view
end

-- Actions run from scripts change server state only; the app has to be told to follow.
function M.show(session_id, window_id)
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

-- Focusing a floating layer ends the window's zoom, so the popup re-zooms the pane when its command exits.
local rezoom = [["$@"; status=$?; "$REX_BIN_DIR/rex" -S "$REX_SERVER" api call session.zoom_block "{\"session_id\":\"$REX_SESSION\",\"block_id\":\"$0\",\"zoom\":true}" >/dev/null; exit $status]]

local function active_zoom(session_id)
  local windows, view = M.windows(session_id)
  for _, window in ipairs(windows) do
    if window.window_id == view.active_window_id then return window.zoomed_block_id end
  end
end

-- Scripts can pass `cwd` and space-separated extra `args` for the popup command.
function M.popup_action(name, title, command, width, height)
  rex.action{
    name = name,
    title = title,
    args = { cwd = "string?", args = "string?" },
    run = function(ctx, args)
      local cwd = args.cwd
      if cwd == nil or cwd == "" then cwd = M.foreground_cwd() end
      local full = {}
      for _, word in ipairs(command) do table.insert(full, word) end
      for word in (args.args or ""):gmatch("%S+") do table.insert(full, word) end
      local zoomed = active_zoom(ctx.session_id)
      if zoomed then
        for i, word in ipairs({ "sh", "-c", rezoom, zoomed }) do table.insert(full, i, word) end
      end
      return rex.session.new_layer{
        session_id = ctx.session_id,
        bounds = { (1 - width) / 2, (1 - height) / 2, width, height },
        focus = true,
        layout = rex.layout.block{
          flavor = M.shell,
          label = title,
          options = { command = full, cwd = cwd },
        },
      }
    end,
  }
end

-- Hiding detaches the block instead of closing it, so the command keeps running and reappears as it was.
function M.persistent_popup_action(name, title, command, width, height)
  local bounds = { (1 - width) / 2, (1 - height) / 2, width, height }
  rex.action{
    name = name,
    title = title,
    run = function(ctx)
      local session_id = ctx.session_id
      local view = rex.session.view{ session_id = session_id }
      local active
      for _, window in ipairs(view.windows or {}) do
        if window.window_id == view.active_window_id then active = window end
        for _, layer in ipairs(window.layers or {}) do
          for _, block in ipairs(layer.kind == "floating" and layer.blocks or {}) do
            if block.label == title then
              rex.session.detach_block{ session_id = session_id, block_id = block.block_id }
              if window == active then return end
            end
          end
        end
      end

      local detached
      for _, block in ipairs(rex.session.list_blocks{ session_id = session_id }.blocks or {}) do
        if block.label == title and block.placement == "detached" then detached = block.block_id end
      end
      if detached == nil then
        return rex.session.new_layer{
          session_id = session_id,
          bounds = bounds,
          focus = true,
          layout = rex.layout.block{ flavor = M.shell, label = title, options = { command = command } },
        }
      end

      -- A detached block can only be placed beside a tiled one, then floated from there.
      local anchor
      for _, layer in ipairs(active.layers or {}) do
        if layer.kind == "tiled" then
          local node = layer.layout
          while node.split do node = node.split.before end
          anchor = node.block_id
        end
      end
      rex.session.move_block{ session_id = session_id, block_id = detached, anchor_block_id = anchor }
      rex.session.float_block{ session_id = session_id, block_id = detached, bounds = bounds }
      return rex.session.focus_block{ session_id = session_id, block_id = detached }
    end,
  }
end

return M
