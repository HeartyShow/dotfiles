-- Ctrl+hjkl moves between nvim splits, then across Rex panes at the edge.
-- Goes through Rex's `focus_pane` action (not `rex focus`) so Rex remembers the pane we left.
if not vim.env.REX_SESSION or not vim.env.REX_BIN_DIR then
  return {}
end

-- Floats placed inside a split (e.g. the snacks explorer) navigate from that split,
-- otherwise `wincmd` from a float jumps back into the editor instead of stopping at the edge.
local function anchor(win)
  local config = vim.api.nvim_win_get_config(win)
  while config.relative == "win" and config.win do
    win = config.win
    config = vim.api.nvim_win_get_config(win)
  end
  return win
end

local function navigate(wincmd, direction)
  local win = vim.api.nvim_get_current_win()
  local from = anchor(win)
  local target = vim.api.nvim_win_call(from, function()
    return vim.fn.win_getid(vim.fn.winnr(wincmd))
  end)
  if target == from then
    vim.system({ vim.env.REX_BIN_DIR .. "/rex", "do", "focus_pane", "direction=" .. direction })
  elseif from == win then
    vim.cmd.wincmd(wincmd)
  else
    vim.api.nvim_set_current_win(target)
  end
end

-- After VimEnter so these win over nvim-tmux-navigation's lazy-loaded mappings.
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    for wincmd, direction in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
      vim.keymap.set("n", "<C-" .. wincmd .. ">", function()
        navigate(wincmd, direction)
      end, { desc = "Navigate " .. direction .. " (Neovim/Rex)" })
    end
  end,
})

return {}
