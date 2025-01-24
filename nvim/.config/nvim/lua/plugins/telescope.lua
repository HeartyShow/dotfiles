return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.8",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope-project.nvim",
		"nvim-telescope/telescope-live-grep-args.nvim",
		"nvim-telescope/telescope-file-browser.nvim",
	},
	opts = function()
		local builtin = require("telescope.builtin")
		local actions = require("telescope.actions")
		return {
			defaults = {
				path_display = {
					smart = true,
				},
				mappings = {
					i = {
						["<C-v>"] = actions.select_vertical,
						["<C-b>"] = actions.select_horizontal,
						["<C-t>"] = require("trouble.sources.telescope").open,
						["<C-j>"] = actions.move_selection_next,
						["<C-k>"] = actions.move_selection_previous,
					},
					n = {
						["<C-t>"] = require("trouble.sources.telescope").add,
					},
				},
				sorting_strategy = "ascending",
				prompt_prefix = " ",
				selection_caret = " ",
				entry_prefix = "  ",
				results_title = false,
				layout_config = {
					horizontal = {
						prompt_position = "top",
						preview_width = 0.65,
						results_width = 0.8,
					},
					vertical = {
						mirror = false,
					},
					width = 0.87,
					height = 0.80,
					preview_cutoff = 120,
				},
				vimgrep_arguments = {
					"rg",
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
					"--smart-case",
					"--hidden",
					"-u",
				},
				file_ignore_patterns = {
					"node_modules",
					".git/",
				},
			},
			pickers = {
				find_files = {
					find_command = {
						"fd",
						"--type",
						"f",
						"--color=never",
						"--hidden",
						"--follow",
					},
				},
			},
			extensions = {
				project = {
					order_by = "recent",
					search_by = { "title", "path" },
					on_project_selected = function(prompt_bufnr)
						require("telescope._extensions.project.actions").change_working_directory(prompt_bufnr, false)
						builtin.find_files()
					end,
				},
			},
		}
	end,
	config = function(_, opts)
		require("telescope").setup(opts)
		local builtin = require("telescope.builtin")
		local action_state = require("telescope.actions.state")
		local actions = require("telescope.actions")

		-- Helper functions

		local buffer_searcher
		buffer_searcher = function()
			builtin.buffers({
				sort_mru = true,
				ignore_current_buffer = true,
				show_all_buffers = false,
				attach_mappings = function(prompt_bufnr, map)
					local refresh_buffer_searcher = function()
						actions.close(prompt_bufnr)
						vim.schedule(buffer_searcher)
					end
					local delete_buf = function()
						local selection = action_state.get_selected_entry()
						vim.api.nvim_buf_delete(selection.bufnr, { force = true })
						refresh_buffer_searcher()
					end
					local delete_multiple_buf = function()
						local picker = action_state.get_current_picker(prompt_bufnr)
						local selection = picker:get_multi_selection()
						for _, entry in ipairs(selection) do
							vim.api.nvim_buf_delete(entry.bufnr, { force = true })
						end
						refresh_buffer_searcher()
					end
					map("n", "dd", delete_buf)
					map("n", "<C-d>", delete_multiple_buf)
					map("i", "<C-d>", delete_multiple_buf)
					return true
				end,
			})
		end

		-- Base keymaps

		vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find file in current project" })
		vim.keymap.set("n", "<leader>fb", buffer_searcher, { desc = "Find opened buffers" })
		vim.keymap.set("n", "<leader>fo", builtin.oldfiles, { desc = "Find recently opened files", silent = true })
		vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Search help tags", silent = true })
		vim.keymap.set(
			"n",
			"<leader>/",
			builtin.current_buffer_fuzzy_find,
			{ desc = "Find in current file", silent = true }
		)

		-- Extensions keymap

		require("telescope").load_extension("file_browser")
		vim.keymap.set(
			"n",
			"<space>fl",
			":Telescope file_browser<CR>",
			{ desc = "Find in current project", silent = true }
		)

		require("telescope").load_extension("aerial")
		vim.keymap.set("n", "<leader>fs", ":Telescope aerial<CR>", { desc = "Find in current project", silent = true })

		require("telescope").load_extension("project")
		vim.keymap.set(
			"n",
			"<leader>fp",
			":lua require'telescope'.extensions.project.project{display_type = 'full'}<CR>",
			{ desc = "Find a project", silent = true }
		)

		require("telescope").load_extension("live_grep_args")
		vim.keymap.set(
			"n",
			"<leader>fg",
			":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>",
			{ desc = "Find in current project", silent = true }
		)
	end,
}
