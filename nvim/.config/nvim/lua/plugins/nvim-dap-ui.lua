-- Nvim-Dap-UI is a UI for nvim-dap, a Debug Adapter Protocol client for Neovim.
return {
	"rcarriga/nvim-dap-ui",
	dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
	config = function()
		local dap, dapui = require("dap"), require("dapui")

		dap.defaults.fallback.terminal_win_cmd = "20split new"
		vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DapBreakpoint", linehl = "", numhl = "" })
		vim.fn.sign_define(
			"DapBreakpointRejected",
			{ text = "", texthl = "DapBreakpointRejected", linehl = "", numhl = "" }
		)
		vim.fn.sign_define("DapStopped", { text = "", texthl = "DapStopped", linehl = "", numhl = "" })

		vim.keymap.set("n", "<leader>db", function()
			require("dap").toggle_breakpoint()
		end)
		vim.keymap.set(
			"n",
			"<leader>dB",
			":lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>"
		)
		vim.keymap.set({ "n", "t" }, "<leader>dk", function()
			require("dap").step_out()
		end)
		vim.keymap.set({ "n", "t" }, "<leader>dl", function()
			require("dap").step_into()
		end)
		vim.keymap.set({ "n", "t" }, "<leader>dj", function()
			require("dap").step_over()
		end)
		vim.keymap.set({ "n", "t" }, "<leader>dh", function()
			require("dap").continue()
		end)
		vim.keymap.set("n", "<leader>dn", function()
			require("dap").run_to_cursor()
		end)
		vim.keymap.set("n", "<leader>dc", function()
			require("dap").terminate()
		end)
		vim.keymap.set("n", "<leader>dR", function()
			require("dap").clear_breakpoints()
		end)
		vim.keymap.set("n", "<leader>de", function()
			require("dap").set_exception_breakpoints({ "all" })
		end)
		-- vim.keymap.set("n", "<leader>da", function()
		-- 	require("debugHelper").attach()
		-- end)
		-- vim.keymap.set("n", "<leader>dA", function()
		-- 	require("debugHelper").attachToRemote()
		-- end)
		vim.keymap.set("n", "<leader>du", function()
			require("dap.ui.widgets").hover()
		end)
		vim.keymap.set("n", "<leader>d?", function()
			local widgets = require("dap.ui.widgets")
			widgets.centered_float(widgets.scopes)
		end)
		-- vim.keymap.set("n", "<leader>dk", ':lua require"dap".up()<CR>zz')
		-- vim.keymap.set("n", "<leader>dj", ':lua require"dap".down()<CR>zz')
		vim.keymap.set("n", "<leader>dr", ':lua require"dap".repl.toggle({}, "vsplit")<CR><C-w>l')
		vim.keymap.set("n", "<leader>dd", ':lua require"dapui".toggle()<CR>')

		-- Open dapui automatically when debug session is created
		require("dapui").setup()
		dap.listeners.before.attach.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.launch.dapui_config = function()
			dapui.open()
		end
		-- dap.listeners.before.event_terminated.dapui_config = function()
		-- 	dapui.close()
		-- end
		-- dap.listeners.before.event_exited.dapui_config = function()
		-- 	dapui.close()
		-- end

		-- Custom keymap to close hover window
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "dap-float",
			callback = function()
				vim.api.nvim_buf_set_keymap(0, "n", "q", "<cmd>close!<CR>", { noremap = true, silent = true })
				vim.api.nvim_buf_set_keymap(0, "n", "<Esc>", "<cmd>close!<CR>", { noremap = true, silent = true })
			end,
		})
	end,
}
