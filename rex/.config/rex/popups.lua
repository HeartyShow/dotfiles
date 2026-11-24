local lib = require("lib")

local function bounds(width, height)
  return { (1 - width) / 2, (1 - height) / 2, width, height }
end

-- Focusing a floating layer ends the window's zoom, so the popup re-zooms the pane when its command exits.
local rezoom = [["$@"; status=$?; "$REX_BIN_DIR/rex" api call session.zoom_block "{\"session_id\":\"$REX_SESSION\",\"block_id\":\"$0\",\"zoom\":true}" >/dev/null; exit $status]]

-- Scripts can pass `cwd` and space-separated extra `args` for the popup command.
local function popup(name, title, command, width, height)
  rex.action{
    name = name,
    title = title,
    args = { cwd = "string?", args = "string?" },
    run = function(ctx, args)
      local cwd = args.cwd
      if cwd == nil or cwd == "" then cwd = lib.foreground_cwd() end
      local full = {}
      for _, word in ipairs(command) do full[#full + 1] = word end
      for word in (args.args or ""):gmatch("%S+") do full[#full + 1] = word end
      local window = lib.active_window(ctx.session_id)
      if window and window.zoomed_block_id then
        for i, word in ipairs({ "sh", "-c", rezoom, window.zoomed_block_id }) do table.insert(full, i, word) end
      end
      return rex.session.new_layer{
        session_id = ctx.session_id,
        bounds = bounds(width, height),
        focus = true,
        layout = rex.layout.block{ flavor = lib.shell, label = title, options = { command = full, cwd = cwd } },
      }
    end,
  }
end

-- Hiding detaches the block instead of closing it, so the command keeps running and reappears as it was.
local function persistent_popup(name, title, command, width, height)
  rex.action{
    name = name,
    title = title,
    run = function(ctx)
      local session_id = ctx.session_id
      local windows, view = lib.windows(session_id)
      for _, window in ipairs(windows) do
        for _, layer in ipairs(window.layers or {}) do
          for _, block in ipairs(layer.kind == "floating" and layer.blocks or {}) do
            if block.label == title then
              rex.session.detach_block{ session_id = session_id, block_id = block.block_id }
              if window.window_id == view.active_window_id then return end
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
          bounds = bounds(width, height),
          focus = true,
          layout = rex.layout.block{ flavor = lib.shell, label = title, options = { command = command } },
        }
      end

      -- A detached block can only be placed beside a tiled one, then floated from there.
      local anchor
      for _, layer in ipairs(lib.active_window(session_id).layers or {}) do
        if layer.kind == "tiled" then
          local node = layer.layout
          while node.split do node = node.split.before end
          anchor = node.block_id
        end
      end
      if anchor == nil then error("No tiled pane to show " .. title .. " over", 0) end
      rex.session.move_block{ session_id = session_id, block_id = detached, anchor_block_id = anchor }
      rex.session.float_block{ session_id = session_id, block_id = detached, bounds = bounds(width, height) }
      return rex.session.focus_block{ session_id = session_id, block_id = detached }
    end,
  }
end

popup("popup_gh_dash", "GitHub Dashboard (gh-dash)", { "gh-dash" }, 0.95, 0.9)
popup("popup_tuicr", "Review Worktree Changes (tuicr)", { "tuicr" }, 0.95, 0.9)
persistent_popup("popup_slack", "Slack (slk)", { "slk" }, 0.95, 0.9)
persistent_popup("popup_assistant", "Assistant (OpenCode)", { "sh", lib.home .. "/.config/opencode-assistant/assistant.sh" }, 0.95, 0.9)

rex.bind("ctrl+space>g", "popup_gh_dash")
rex.bind("ctrl+space>t", "popup_tuicr")
rex.bind("ctrl+space>s", "popup_slack")
rex.bind("ctrl+space>a", "popup_assistant")
