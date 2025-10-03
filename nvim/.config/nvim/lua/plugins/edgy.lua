-- Edgy is a plugin that provides a better way to manage and organize your Neovim windows and buffers.
return {
	"folke/edgy.nvim",
	opts = function(_, opts)
		opts.right = opts.right or {}
		opts.left = opts.left or {}
		table.insert(opts.right, {
			ft = "copilot-chat",
			title = "Copilot Chat",
			size = { width = 50 },
		})

		table.insert(opts.left, {
			ft = "neo-tree",
			title = "Neo-Tree",
			size = { width = 40 },
		})
	end,
}
