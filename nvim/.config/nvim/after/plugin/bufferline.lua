local bufferline = require("bufferline")
local colors = require("catppuccin.palettes").get_palette()

bufferline.setup({
    options = {
        diagnostics = "nvim_lsp",
        diagnostics_update_in_insert = false,
        offsets = {
            {
                filetype = "NvimTree",
                text = "Explorer",
                separator = true,
                text_align = "center",
                highlight = "PanelHeading",
            },
            {
                filetype = "neo-tree",
                text = "Explorer",
                separator = true,
                text_align = "center",
                highlight = "PanelHeading",
            },
            {
                filetype = "undotree",
                text = "Undotree",
                separator = true,
                text_align = "center",
                highlight = "PanelHeading",
            },
            {
                filetype = "packer",
                text = "Packer",
                separator = true,
                text_align = "center",
                highlight = "PanelHeading",
            },
            {
                filetype = "dapui_scopes",
                text = "Debugger",
                separator = true,
                text_align = "center",
                highlight = "PanelHeading",
            },
        },
        show_buffer_close_icons = false,
        show_close_icon = false,
        sort_by = "insert_after_current",
        diagnostics_indicator = function(count, level, diagnostics_dict, context)
            local icon = level:match("error") and " " or " "
            return " " .. icon .. count
        end,
        indicator = {
            style = 'icon',
        },
        separator_style = "slant"
    },
    highlights = require("catppuccin.groups.integrations.bufferline").get({
        custom = {
            all = {
                buffer_selected = { fg = colors.text },
            },
        },
    }),
})

local map = vim.keymap.set
map("n", "<C-,>", function()
    bufferline.cycle(-1)
end, { desc = "bufferline: Move prev" })

map("n", "<C-;>", function()
    bufferline.cycle(1)
end, { desc = "bufferline: Move next" })

map("n", "<C->>", "<Cmd>:BufferLineMoveNext<CR>")
map("n", "<C-<>", "<Cmd>:BufferLineMovePrev<CR>")
map("n", "<C-:>", "<Cmd>:BufferLineTogglePin<CR>")
map("n", "<C-=>", "<Cmd>:Bdelete<CR>")
