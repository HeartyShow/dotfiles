-- Nvim-DAP is a Debug Adapter Protocol client implementation for Neovim.
return {
	"mfussenegger/nvim-dap",
	config = function()
		require("dap.ext.vscode").load_launchjs(nil, {})
	end,
}
