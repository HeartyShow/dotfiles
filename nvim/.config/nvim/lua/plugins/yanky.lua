return {
  "gbprod/yanky.nvim",
  opts = {
    ring = {
      ignore_registers = { "_", "+", "*" }, -- Ignore black hole and clipboard registers
      sync_with_numbered_registers = false,
    },
    system_clipboard = {
      sync_with_ring = false, -- Disable system clipboard sync
    },
    highlight = { timer = 150 },
    preserve_cursor_position = {
      enabled = true,
    },
  },
  keys = {
    -- Keep only the yank history picker
    {
      "<leader>p",
      function()
        if LazyVim.pick.picker.name == "telescope" then
          require("telescope").extensions.yank_history.yank_history({})
        elseif LazyVim.pick.picker.name == "snacks" then
          Snacks.picker.yanky()
        else
          vim.cmd([[YankyRingHistory]])
        end
      end,
      mode = { "n", "x" },
      desc = "Open Yank History",
    },
    -- Override visual mode paste to not yank selection
    { "p", [["_dP]], mode = "x", desc = "Paste without yanking selection" },
    { "c", [["_c]], mode = "x", desc = "Change without yanking" },
    -- Keep normal mode yanky behavior
    { "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank Text" },
    { "p", "<Plug>(YankyPutAfter)", mode = "n", desc = "Put Text After Cursor" },
    { "P", "<Plug>(YankyPutBefore)", mode = "n", desc = "Put Text Before Cursor" },
  },
}
