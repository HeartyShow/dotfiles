-- Help-VSplit is a Neovim plugin that opens help files in a vertical split.
return {
	"anuvyklack/help-vsplit.nvim",
	opts = {
		side = "left",
	},
	config = function(_, opts)
		require("help-vsplit").setup(opts)
	end,
}
