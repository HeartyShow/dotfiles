local builtin = require('telescope.builtin')

-- Base keymaps

vim.keymap.set('n', '<leader>?', builtin.oldfiles, { desc = 'Find recently opened files', silent = true })
vim.keymap.set('n', '<leader>/', builtin.current_buffer_fuzzy_find, { desc = 'Find in current file', silent = true })
vim.keymap.set('n', '<leader>fs', builtin.find_files, { desc = 'Find file in current project', silent = true })
vim.keymap.set('n', '<leader>h', builtin.help_tags, { desc = 'Search help tags', silent = true })

-- Custom keymap

local project_files = function()
    local _, ret, _ = require('telescope.utils').get_os_command_output({ 'git', 'rev-parse', '--is-inside-work-tree' })
    if ret == 0 then
        builtin.git_files()
    else
        builtin.find_files()
    end
end

vim.keymap.set('n', '<c-p>', project_files, { desc = 'Find file in current project' })

-- Config

local actions = require("telescope.actions")
require("telescope").setup({
    defaults = {
        path_display = {
            smart = true
        },
        mappings = {
            i = {
                ["<C-v>"] = actions.select_vertical,
                ["<C-b>"] = actions.select_horizontal,
            }
        },
        layout_config = {
            horizontal = {
                prompt_position = "top",
                preview_width = 0.55,
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
            'rg',
            '--color=never',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
            '--smart-case',
            '-u'
        },
        file_ignore_patterns = {
            'node_modules',
            '.git'
        },
    },
    extensions = {
        project = {
            order_by = "recent",
            search_by = { "title", "path" },
            on_project_selected = function(prompt_bufnr)
                require("telescope._extensions.project.actions").change_working_directory(prompt_bufnr, false)
                project_files()
            end
        }
    }
})

-- Extensions keymap

require("telescope").load_extension("file_browser")
vim.keymap.set("n", "<space>fb", ":Telescope file_browser<CR>", { desc = 'Find in current project', silent = true })

require("telescope").load_extension("aerial")
vim.keymap.set('n', '<leader>o', ':Telescope aerial<CR>', { desc = 'Find in current project', silent = true })

require("telescope").load_extension("project")
vim.keymap.set("n", "<leader>pr", ":lua require'telescope'.extensions.project.project{display_type = 'full'}<CR>",
    { desc = 'Find a project', silent = true })

require("telescope").load_extension("live_grep_args")
vim.keymap.set("n", "<leader>lg", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>",
    { desc = 'Find in current project', silent = true })

-- Highlighting groups

local cmd = vim.cmd
local colors = require("catppuccin.palettes").get_palette()

local bg = function(group, col)
    cmd("hi " .. group .. " guibg=" .. col)
end

local fg = function(group, col)
    cmd("hi " .. group .. " guifg=" .. col)
end

local fg_bg = function(group, fgcol, bgcol)
    cmd("hi " .. group .. " guifg=" .. fgcol .. " guibg=" .. bgcol)
end

local clear = colors.surface0
local mid = colors.mantle
local dark = colors.crust

fg_bg("TelescopeBorder", dark, dark)
fg_bg("TelescopePromptBorder", clear, clear)

fg_bg("TelescopePromptPrefix", colors.flamingo, clear)
fg_bg("TelescopePromptNormal", colors.text, clear)

bg("TelescopeNormal", dark)
bg("TelescopePreviewNormal", mid)
fg_bg("TelescopePreviewBorder", mid, mid)

fg_bg("TelescopePreviewTitle", dark, colors.green)
fg_bg("TelescopePromptTitle", dark, colors.peach)
fg_bg("TelescopeResultsTitle", dark, dark)

bg("TelescopeSelection", clear)
