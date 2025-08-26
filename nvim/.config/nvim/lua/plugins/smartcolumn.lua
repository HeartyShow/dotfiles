-- Smartcolumn is a plugin that highlights the column at a certain width to help you keep your code within a certain line length.
return {
	"m4xshen/smartcolumn.nvim",
	opts = {
		scope = "line",
		disabled_filetypes = {
			"NvimTree",
			"lazy",
			"mason",
			"help",
			"checkhealth",
			"lspinfo",
			"noice",
			"Trouble",
			"fish",
			"zsh",
			"neotree",
			"undotree",
			"alpha",
		},
	},
}
