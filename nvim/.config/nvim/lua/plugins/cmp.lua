-- CMP is a completion engine for neovim written in Lua.
return {
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			-- autopairing of (){}[] etc
			{
				"windwp/nvim-autopairs",
				opts = {
					fast_wrap = {},
					disable_filetype = { "TelescopePrompt", "vim" },
				},
				config = function(_, opts)
					require("nvim-autopairs").setup(opts)

					-- setup cmp for autopairs
					local cmp_autopairs = require("nvim-autopairs.completion.cmp")
					require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
				end,
			},
			"hrsh7th/cmp-nvim-lua",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"lukas-reineke/cmp-under-comparator",
		},
		opts = function()
			local cmp = require("cmp")
			local lsp = require("lsp-zero")

			local icons = {
				Text = "󰉿",
				Method = "󰆧",
				Function = "󰊕",
				Constructor = "",
				Field = "󰜢",
				Variable = "󰀫",
				Class = "󰠱",
				Interface = "",
				Module = "",
				Property = "󰜢",
				Unit = "󰑭",
				Value = "󰎠",
				Enum = "",
				Keyword = "󰌋",
				Snippet = "",
				Color = "󰏘",
				File = "󰈙",
				Reference = "󰈇",
				Folder = "󰉋",
				EnumMember = "",
				Constant = "󰏿",
				Struct = "󰙅",
				Event = "",
				Operator = "󰆕",
				Copilot = "",
			}

			local cmp_mappings = lsp.defaults.cmp_mappings({
				["<C-Space>"] = cmp.mapping.complete(),
				["<C-j>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_next_item()
						return
					end
					fallback()
				end, { "i" }),
				["<C-k>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_prev_item()
						return
					end
					fallback()
				end, { "i" }),
				["<CR>"] = cmp.mapping.confirm({ select = true }),
				["<Tab>"] = cmp.mapping.confirm({ select = true }),
			})

			return {
				mapping = cmp_mappings,
				formatting = {
					fields = { "kind", "abbr" },
					format = function(_, vim_item)
						vim_item.menu = nil
						vim_item.kind = icons[vim_item.kind]
						return vim_item
					end,
				},
				completion = {
					completeopt = "menu,menuone,noinsert",
				},
				performance = {
					max_view_entries = 15,
				},
				sources = {
					{ name = "nvim_lsp", group_index = 2 },
					{ name = "path", group_index = 2 },
					{ name = "luasnip", group_index = 2 },
					{ name = "copilot", group_index = 2 },
				},
				sorting = {
					comparators = {
						cmp.config.compare.exact,
						require("copilot_cmp.comparators").prioritize,
						cmp.config.compare.offset,
						cmp.config.compare.score,
						cmp.config.compare.recently_used,
						require("cmp-under-comparator").under,
						cmp.config.compare.kind,
					},
				},
			}
		end,
		config = function(_, opts)
			cmp = require("cmp")
			cmp.setup(opts)
			cmp.setup.cmdline("/", {
				mapping = {
					["<C-j>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							return cmp.select_next_item()
						end
						fallback()
					end, { "c" }),
					["<C-k>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							return cmp.select_prev_item()
						end
						fallback()
					end, { "c" }),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							return cmp.confirm({ select = true })
						end
						fallback()
					end, { "c" }),
				},

				sources = {
					{ name = "buffer" },
				},
			})
			cmp.setup.cmdline(":", {
				mapping = {
					["<C-j>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							return cmp.select_next_item()
						end
						fallback()
					end, { "c" }),
					["<C-k>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							return cmp.select_prev_item()
						end
						fallback()
					end, { "c" }),
					["<CR>"] = cmp.mapping.confirm({ select = true }),

					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							return cmp.confirm({ select = true })
						end
						fallback()
					end, { "c" }),
				},

				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{ name = "cmdline" },
				}),
				matching = { disallow_symbol_nonprefix_matching = false },
			})
		end,
	},
}
