return {
	"mfussenegger/nvim-dap-python",
	enabled = false,
	dependencies = { "mfussenegger/nvim-dap" },
	-- use a tiny, per–plugin Lua 5.1 via hererocks
	opts = {
		rocks = {
			enabled = false,
			hererocks = true,
		},
	},
	config = function(_, opts)
		-- this will bootstrap hererocks, install nvim-dap & nvim-dap-python libs
		require("dap-python").setup("$HOME/.pyenv/shims/python", opts)

		-- pick pytest as your test runner
		require("dap-python").test_runner = "pytest"

		-- example keymap to run the current method’s tests
		vim.keymap.set("n", "<leader>dt", function()
			require("dap-python").test_method()
		end, { desc = "DAP: test_method()" })
	end,
}
