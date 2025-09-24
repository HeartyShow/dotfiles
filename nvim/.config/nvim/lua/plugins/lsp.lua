-- Lsp Config covers all LSP related shaenigans
return {
	"VonHeikemen/lsp-zero.nvim",
	branch = "v3.x",
	dependencies = {
		-- LSP Support
		{ "neovim/nvim-lspconfig" },
		-- { "williamboman/mason.nvim" },
		-- { "WhoIsSethDaniel/mason-tool-installer.nvim" },
		-- { "williamboman/mason-lspconfig.nvim" },
		{
			"WieeRd/auto-lsp.nvim",
			dependencies = { "neovim/nvim-lspconfig" },
			event = "VeryLazy",
			opts = {
				["pylsp"] = false,
			},
		},

		-- Autocompletion
		{ "hrsh7th/nvim-cmp" },
		{ "hrsh7th/cmp-buffer" },
		{ "hrsh7th/cmp-path" },
		{ "saadparwaiz1/cmp_luasnip" },
		{ "hrsh7th/cmp-nvim-lsp" },
		{ "hrsh7th/cmp-nvim-lua" },

		-- Snippets
		{ "L3MON4D3/LuaSnip" },
		{ "rafamadriz/friendly-snippets" },

		-- Helper
		{ "hrsh7th/cmp-nvim-lsp-signature-help" },
	},
	config = function()
		local lsp = require("lsp-zero")

		lsp.preset("recommended")

		-- Fix Undefined global 'vim'
		lsp.set_preferences({
			suggest_lsp_servers = false,
			sign_icons = {
				error = "E",
				warn = "W",
				hint = "H",
				info = "I",
			},
		})

		lsp.on_attach(function(_, bufnr)
			local nmap = function(keys, func, desc)
				if desc then
					desc = "LSP: " .. desc
				end

				vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
			end

			nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
			nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

			nmap("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
			nmap("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
			nmap("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
			nmap("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
			nmap("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")

			-- See `:help K` for why this keymap
			nmap("<C-u>", vim.lsp.buf.hover, "Hover Documentation")
			nmap("<C-x>", vim.diagnostic.open_float, "Hover Diagnostics")

			-- Lesser used LSP functionality
			nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
			nmap("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
			nmap("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
			nmap("<leader>wl", function()
				print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
			end, "[W]orkspace [L]ist Folders")
		end)

		lsp.setup()

		vim.diagnostic.config({
			virtual_text = true,
		})

		vim.fn.sign_define("DiagnosticSignError", { text = "", texthl = "DiagnosticSignError" })
		vim.fn.sign_define("DiagnosticSignWarn", { text = "", texthl = "DiagnosticSignWarn" })
		vim.fn.sign_define("DiagnosticSignInfo", { text = "", texthl = "DiagnosticSignInfo" })
		vim.fn.sign_define("DiagnosticSignHint", { text = "", texthl = "DiagnosticSignHint" })

		-- CDS
		local configs = require("lspconfig.configs")
		if not configs.sapcds_lsp then
			configs.sapcds_lsp = {
				default_config = {
					cmd = {
						"cds-lsp",
						"--stdio",
					},
					filetypes = { "cds" },
					root_dir = require("lspconfig").util.root_pattern(".git", "package.json"),
					settings = {},
				},
			}
		end
		if require("lspconfig").sapcds_lsp.setup then
			require("lspconfig").sapcds_lsp.setup({
				-- capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
			})
		end

		-- Mason
		-- local mason_tool_installer = require("mason-tool-installer")
		-- require("mason").setup()
		-- require("mason-lspconfig").setup({
		-- 	handlers = {
		-- 		function(server_name)
		-- 			require("lspconfig")[server_name].setup({})
		-- 		end,
		-- 		lua_ls = function()
		-- 			local lua_opts = lsp.nvim_lua_ls()
		-- 			require("lspconfig").lua_ls.setup(lua_opts)
		-- 		end,
		-- 		jdtls = lsp.noop,
		-- 	},
		-- })

		-- mason_tool_installer.setup({
		-- 	ensure_installed = {
		-- 		"prettier", -- prettier formatter
		-- 		"stylua", -- lua formatter
		-- 		"ruff", -- python formatter
		-- 		"pyright", -- python STC
		-- 		"eslint_d", -- js linter
		-- 	},
		-- })

		-- Python
		-- require('lspconfig').ruff.setup({
		--     init_options = {
		--         settings = {
		--             -- Ruff language server settings go here
		--         }
		--     }
		-- })

		-- vim.g.python3_host_prog = "<home-path>.pyenv/versions/neovim/bin/python"

		require("lspconfig").pyright.setup({
			settings = {
				pyright = {
					-- Using Ruff's import organizer
					disableOrganizeImports = true,
				},
				python = {
					analysis = {
						-- Ignore all files for analysis to exclusively use Ruff for linting
						ignore = { "*" },
					},
				},
			},
		})

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("lsp_attach_disable_ruff_hover", { clear = true }),
			callback = function(args)
				local client = vim.lsp.get_client_by_id(args.data.client_id)
				if client == nil then
					return
				end
				if client.name == "ruff" then
					-- Disable hover in favor of Pyright
					client.server_capabilities.hoverProvider = false
				end
			end,
			desc = "LSP: Disable hover capability from Ruff",
		})
	end,
}
