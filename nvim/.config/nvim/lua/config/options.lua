-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.clipboard = ""

if vim.fn.has("wsl") == 1 and not vim.fn.has("mac") then
  vim.g.clipboard = {
    name = "win_clipboard",
    copy = {
      ["+"] = "clip.exe",
      ["*"] = "clip.exe",
    },
    paste = {
      ["+"] = "powershell.exe Get-Clipboard",
      ["*"] = "powershell.exe Get-Clipboard",
    },
    cache_enabled = 0,
  }
end
