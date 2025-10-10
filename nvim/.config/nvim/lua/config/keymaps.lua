-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Disabled keymaps
vim.keymap.set("i", "<C-j>", "<Nop>", { silent = true })
vim.keymap.set({ "n", "v" }, "J", "<Nop>", { silent = true })

-- Copy to system clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- Center when moving
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")
