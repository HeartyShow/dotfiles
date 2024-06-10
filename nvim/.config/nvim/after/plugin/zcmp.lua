local cmp = require('cmp')
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
}

local cmp_mappings = lsp.defaults.cmp_mappings({
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ["<C-Space>"] = cmp.mapping.complete(),
    ['<Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
            cmp.select_next_item()
            return
        end
        fallback()
    end
    , { 'i' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
            cmp.select_prev_item()
            return
        end
        fallback()
    end
    , { 'i' }),
})

cmp.setup({
    mapping = cmp_mappings,
    formatting = {
        fields = { 'abbr', 'kind' },
        format = function(_, vim_item)
            vim_item.menu = nil
            vim_item.kind = (icons[vim_item.kind])
            return vim_item
        end,
    },
    completion = {
        completeopt = "menu,menuone,noinsert",
    },
    performance = {
        max_view_entries = 15,
    }
})
