-- Zenmode is a plugin that provides a distraction-free coding experience by centering the text and hiding unnecessary UI elements.
return {
	"folke/zen-mode.nvim",
	opts = {
		window = {
			options = {},
			width = 0.8,
			height = 1,
		},
		plugins = {
			gitsigns = {
				enabled = false,
			},
			tmux = {
				enabled = false,
			},
		},
	},
	config = function(_, opts)
		local zen = require("zen-mode")
		zen.setup(opts)
		vim.keymap.set("n", "<leader>zz", function()
			zen.toggle()
			vim.wo.wrap = false
			vim.wo.number = true
			vim.wo.rnu = true
		end)
	end,
}
