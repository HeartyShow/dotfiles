return {
	"folke/snacks.nvim",
	opts = {
		input = { enabled = true },
		scroll = { enabled = true },
		lazygit = { enabled = true, theme = {} },
	},
  -- stylua: ignore
  keys = {
    {"<leader>gi", function() require("snacks").lazygit() end, { desc = "Lazygit" }}
  },
}
