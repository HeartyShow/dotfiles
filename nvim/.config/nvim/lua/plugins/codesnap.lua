-- Codesnap is a plugin to take beautiful screenshots of your code.
return {
	"mistricky/codesnap.nvim",
	build = "make",
	opts = {
		has_breadcrumbs = true,
		bg_theme = "dusk",
		watermark = "",
		code_font_family = "JetBrainsMono Nerd Font Mono",
		bg_x_padding = 30,
		bg_y_padding = 30,
	},
	config = function(_, opts)
		require("codesnap").setup(opts)
	end,
}
