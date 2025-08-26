-- Copilot lua is a plugin rewritten in lua that provides an interface to GitHub Copilot.
return {
	"zbirenbaum/copilot.lua",
	cmd = "Copilot",
	event = "InsertEnter",
	config = function()
		require("copilot").setup()
	end,
}
