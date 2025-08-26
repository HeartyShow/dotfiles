-- Copilot-CMP is a plugin that integrates GitHub Copilot with nvim-cmp.
return {
	"zbirenbaum/copilot-cmp",
	config = function()
		require("copilot_cmp").setup()
	end,
}
