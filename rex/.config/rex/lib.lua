local M = {}

M.home = os.getenv("HOME")
M.terminal = "com.superlogical.terminal"
M.shell = "com.superlogical.terminal.shell"
-- The server runs with launchd's bare PATH, which lacks Nix tools such as zoxide.
M.path = "/run/current-system/sw/bin:/usr/bin:/bin:/usr/sbin:/sbin"

function M.tilde(path)
  return (path:gsub("^" .. M.home:gsub("%p", "%%%0"), "~"))
end

function M.basename(path)
  return path:match("([^/]+)/?$")
end

function M.lines(command, cwd)
  local result = rex.exec(command, { cwd = cwd, env = { PATH = M.path } })
  local out = {}
  if result and result.ok then
    for line in result.stdout:gmatch("[^\n]+") do out[#out + 1] = line end
  end
  return out
end

function M.foreground_cwd(block_id)
  local info = rex.block.call(M.terminal, "process", { block_id = block_id })
  return info and info.foreground and info.foreground.cwd
end

function M.windows(session_id)
  local view = rex.session.view{ session_id = session_id }
  return view and view.windows or {}, view
end

function M.active_window(session_id)
  local windows, view = M.windows(session_id)
  for _, window in ipairs(windows) do
    if window.window_id == view.active_window_id then return window end
  end
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

return M
