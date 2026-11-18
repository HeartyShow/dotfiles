-- Ctrl+hjkl moves between nvim splits, then across Rex panes at the edge.
-- Goes through Rex's `focus_pane` action (not `rex focus`) so Rex remembers the pane we left.
if not vim.env.REX_SESSION or not vim.env.REX_BIN_DIR then
  return {}
end

local function navigate(wincmd, direction)
  local win = vim.api.nvim_get_current_win()
  vim.cmd.wincmd(wincmd)
  if vim.api.nvim_get_current_win() == win then
    vim.system({
      vim.env.REX_BIN_DIR .. "/rex", "-S", vim.env.REX_SERVER,
      "do", "-s", vim.env.REX_SESSION, "focus_pane", "direction=" .. direction,
    })
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
