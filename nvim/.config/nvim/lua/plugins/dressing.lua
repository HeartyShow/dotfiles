-- Dressing is a plugin that improves the default Neovim UI components for prompts and selections.
return {
	"stevearc/dressing.nvim",
	opts = {
		input = {
			trim_prompt = true,
			title_pos = "center",
		},
	},
}
