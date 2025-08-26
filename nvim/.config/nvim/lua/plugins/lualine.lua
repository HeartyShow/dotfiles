-- Lualine is a customizable statusline plugin for Neovim written in Lua.
return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"AndreM222/copilot-lualine",
		"letieu/harpoon-lualine",
	},
	opts = {
		options = {
			theme = "auto",
			icons_enabled = true,
			component_separators = "|",
			section_separators = { left = "", right = "" },
			disabled_filetypes = { "packer", "neo-tree", "undotree", "diffpanel" },
		},
		sections = {
			lualine_a = { "mode" },
			lualine_b = {
				"branch",
				"diff",
				{
					"diagnostics",
					sources = { "nvim_diagnostic" },
					symbols = { error = " ", warn = " ", info = " ", hint = " " },
				},
			},
			lualine_c = {
				"filename",
				{ "harpoon2", icon = "󰀱" },
			},
			lualine_x = {
				{
					"copilot",
					symbols = {
						status = {
							icons = {
								enabled = "",
								sleep = "", -- auto-trigger disabled
								disabled = "",
								warning = "",
								unknown = "",
							},
						},
					},
				},
				"encoding",
				"fileformat",
				"filetype",
				{
					"lsp_status",
					ignore_lsp = { "null-ls", "copilot" },
				},
			}, -- I added copilot here
			lualine_y = { "progress" },
			lualine_z = { "location" },
		},
	},
	config = function(_, opts)
		require("lualine").setup(opts)
	end,
}
