local lib = require("lib")

local build = lib.home .. "/.config/rex/scripts/worktrees.sh"
local pending = "⏳ "

local function worktrees(cwd)
  local list, current = {}, nil
  for _, line in ipairs(lib.lines({ "git", "worktree", "list", "--porcelain" }, cwd)) do
    local key, value = line:match("^(%S+)%s?(.*)$")
    if key == "worktree" then
      current = { path = value }
      list[#list + 1] = current
    elseif key == "branch" then
      current.branch = value:gsub("^refs/heads/", "")
    elseif key == "detached" then
      current.branch = "detached"
    elseif key == "bare" then
      current.bare = true
    end
  end
  local out = {}
  for _, worktree in ipairs(list) do
    if not worktree.bare then out[#out + 1] = worktree end
  end
  return out
end

local function tab_named(session_id, name)
  for _, window in ipairs(lib.windows(session_id)) do
    if window.label == name then return window.window_id end
  end
end

local function open(session_id, path, background)
  local name = lib.basename(path)
  local existing = tab_named(session_id, name)
  if existing then
    if background then return end
    rex.call("session.focus_window", { session_id = session_id, window_id = existing })
    return lib.show(session_id, existing)
  end
  local function block(command)
    return rex.layout.block{ flavor = lib.shell, options = { cwd = path, command = command } }
  end
  local created = rex.call("session.new_window", {
    session_id = session_id,
    window_label = name,
    focus = not background,
    layout = rex.layout.horizontal(0.4,
      rex.layout.vertical(0.75, block({ "nvim" }), block(nil)),
      block({ "sh", "-c", "OPENCODE_DISABLE_TERMINAL_TITLE=1 opencode" })),
  })
  -- Take the place of the build tab, which closes once its script exits.
  local placeholder = tab_named(session_id, pending .. name)
  if placeholder then
    rex.call("session.move_window", { session_id = session_id, window_id = created.window_id, before_window_id = placeholder })
  end
  if not background then return lib.show(session_id, created.window_id) end
end

-- The worktree is built in a background tab that opens it when done, so the picker can close right away.
local function create(session_id, repo, name)
  return rex.call("session.new_window", {
    session_id = session_id,
    window_label = pending .. name,
    focus = false,
    layout = rex.layout.block{ flavor = lib.shell, options = { cwd = repo, command = { "sh", build, name } } },
  })
end

local function taken(list, name)
  for _, worktree in ipairs(list) do
    if lib.basename(worktree.path) == name or worktree.branch == name then return true end
  end
end

rex.action{
  name = "open_worktree",
  title = "Open Worktree",
  args = { path = "string", background = "boolean" },
  run = function(ctx, args) return open(ctx.session_id, args.path, args.background) end,
}

rex.action{
  name = "pick_worktree",
  title = "Pick Worktree",
  run = function(ctx)
    local repo = lib.foreground_cwd()
    local list = worktrees(repo)
    if #list == 0 then error("Not in a git repository: " .. tostring(repo), 0) end
    local open_items, other_items = {}, {}
    for _, worktree in ipairs(list) do
      local name = lib.basename(worktree.path)
      local tab = tab_named(ctx.session_id, name)
      local items = tab and open_items or other_items
      items[#items + 1] = {
        id = worktree.path,
        title = name,
        subtitle = (worktree.branch or "?") .. " · " .. lib.tilde(worktree.path),
        icon = "branch",
        detail = tab and "open" or nil,
      }
    end
    for _, item in ipairs(other_items) do open_items[#open_items + 1] = item end

    local title, value = "Worktrees", nil
    while true do
      local choice = rex.ui.pick{
        title = title,
        placeholder = "Pick a worktree, or type a name to create one",
        value = value,
        items = open_items,
        allow_other = true,
      }
      if choice == nil then return end
      if type(choice) ~= "table" then return open(ctx.session_id, choice, false) end
      local name = choice.text:match("^%s*(.-)%s*$")
      if name ~= "" and not taken(list, name) then return create(ctx.session_id, repo, name) end
      title = name == "" and "Worktrees: a name is required" or ("Worktrees: " .. name .. " already exists")
      value = name
    end
  end,
}

rex.bind("ctrl+space>w", "pick_worktree")
