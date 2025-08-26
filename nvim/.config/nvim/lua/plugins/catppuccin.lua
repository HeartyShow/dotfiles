-- Catppuccin is a general color scheme for multiple applications.
return {
	"catppuccin/nvim",
	lazy = false,
	name = "catppuccin",
	priority = 1000,
	opts = function()
		local colors = require("catppuccin.palettes").get_palette()
		return {
			flavour = "mocha", -- latte, frappe, macchiato, mocha
			transparent_background = false, -- disables setting the background color.
			show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
			term_colors = true, -- sets terminal colors (e.g. `g:terminal_color_0`)
			dim_inactive = {
				enabled = false, -- dims the background color of inactive window
				shade = "dark",
				percentage = 0.75, -- percentage of the shade to apply to the inactive window
			},
			no_italic = false, -- Force no italic
			no_bold = false, -- Force no bold
			no_underline = false, -- Force no underline
			styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
				comments = { "italic" }, -- Change the style of comments
				conditionals = { "italic" },
				loops = {},
				functions = {},
				keywords = {},
				strings = {},
				variables = {},
				numbers = {},
				booleans = {},
				properties = {},
				types = {},
				operators = {},
			},
			color_overrides = {},
			integrations = {
				aerial = true,
				alpha = true,
				beacon = true,
				cmp = true,
				gitsigns = true,
				harpoon = true,
				neotree = true,
				nvimtree = false,
				mason = true,
				treesitter = true,
				notify = false,
				indent_blankline = {
					enabled = true,
					scope_color = colors.text, -- catppuccin color (eg. `lavender`) Default: text
					colored_indent_levels = false,
				},
				telescope = {
					enabled = true,
				},
				dap = {
					enabled = true,
					enable_ui = true, -- enable nvim-dap-ui
				},
				mini = {
					enabled = true,
					indentscope_color = "",
				},
			},
		}
	end,
	config = function(_, opts)
		require("catppuccin").setup(opts)
	end,
}
