return {
	"folke/snacks.nvim",
	opts = {
		input = { enabled = true },
		scroll = { enabled = true },
		lazygit = { enabled = true, theme = {} },
	},
  -- stylua: ignore
  keys = {
    { "<leader>n", function()
      local snacks = require("snacks")
      if snacks.config.picker and snacks.config.picker.enabled then
        snacks.picker.notifications()
      else
        snacks.notifier.show_history()
      end
    end, desc = "Notification History" },
    { "<leader>un", function() require("snacks").notifier.hide() end, desc = "Dismiss All Notifications" },
    {"<leader>gi", function() require("snacks").lazygit() end, { desc = "Lazygit" }}
  },
}
