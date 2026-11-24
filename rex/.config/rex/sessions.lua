local lib = require("lib")

local function session_named(name)
  local result = rex.call("session.list")
  for _, session in ipairs(result and result.sessions or {}) do
    if session.label == name then return session.session_id end
  end
end

local function open(name, path)
  local id = session_named(name)
  if id == nil then
    local created, err = rex.call("session.create", {
      label = name,
      initial_windows = { { layout = rex.layout.block{ flavor = lib.shell, options = { cwd = path } } } },
    })
    if err ~= nil then error(err, 0) end
    id = created.session_id
  end
  return lib.show(id)
end

local function session_items(current)
  local items = {}
  local result = rex.call("session.list")
  for _, session in ipairs(result and result.sessions or {}) do
    local windows = lib.windows(session.session_id)
    local first = windows[1]
    local cwd = first and lib.foreground_cwd(first.focused_block_id)
    items[#items + 1] = {
      id = session.session_id,
      title = session.label,
      subtitle = cwd and lib.tilde(cwd),
      icon = "terminal",
      detail = session.session_id == current and "current" or (#windows .. (#windows == 1 and " tab" or " tabs")),
    }
  end
  return items
end

local function zoxide_items()
  local items = {}
  for _, line in ipairs(lib.lines({ "zoxide", "query", "--list", "--score" })) do
    local score, path = line:match("^%s*(%S+)%s+(.+)$")
    if path then
      items[#items + 1] = { id = path, title = lib.basename(path), subtitle = lib.tilde(path), icon = "folder", detail = score }
    end
  end
  return items
end

local function new_session(name)
  local path = rex.ui.pick{ title = "Directory for " .. name, placeholder = "Directory", confirm = "Create session", items = zoxide_items() }
  if path == nil then return end
  return open(name, path)
end

rex.action{
  name = "pick_session",
  title = "Pick Session",
  run = function(ctx)
    local choice = rex.ui.pick{
      title = "Sessions",
      placeholder = "Pick a session, or type a name to create one",
      items = session_items(ctx.session_id),
      allow_other = true,
    }
    if choice == nil then return end
    if type(choice) ~= "table" then return lib.show(choice) end
    local name = choice.text:match("^%s*(.-)%s*$")
    if name == "" then return end
    local existing = session_named(name)
    if existing then return lib.show(existing) end
    return new_session(name)
  end,
}

rex.bind("ctrl+space>f", "pick_session")
