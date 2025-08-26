-- Todo-comment is a plugin that helps you to manage and highlight TODO comments in your code.
return {
	"folke/todo-comments.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	opts = {
		signs = false,
		search = {
			command = "rg",
			args = {
				"--color=never",
				"--no-heading",
				"--with-filename",
				"--line-number",
				"--column",
				"--smart-case",
				"--hidden",
				"-u",
			},
		},
	},
	config = function(_, opts)
		require("todo-comments").setup(opts)
		vim.keymap.set(
			"n",
			"<leader>ft",
			":TodoTelescope<CR>",
			{ desc = "Find Todos in current project", silent = true }
		)
	end,
}
