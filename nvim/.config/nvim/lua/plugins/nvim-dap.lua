-- Nvim-DAP is a Debug Adapter Protocol client implementation for Neovim.
return {
	"mfussenegger/nvim-dap",
	dependencies = { "mfussenegger/nvim-dap-python" },
	config = function()
		require("dap.ext.vscode").load_launchjs(nil, {})

		-- Python
		require("dap-python").setup("$HOME/.pyenv/shims/python")
		require("dap-python").test_runner = "pytest"
		vim.keymap.set("n", "<leader>dt", ':lua require"dap-python".test_method()<CR>')
	end,
}
