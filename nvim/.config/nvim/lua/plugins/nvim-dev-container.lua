-- Nvim-Dev-Container is a Neovim plugin that provides integration with development containers.
return {
	"https://codeberg.org/esensar/nvim-dev-container",
	dependencies = "nvim-treesitter/nvim-treesitter",
	opts = {},
	config = function(_, opts)
		require("devcontainer").setup(opts)
	end,
}
