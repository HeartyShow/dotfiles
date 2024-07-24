require('lualine').setup {
    options = {
        theme = "auto",
        icons_enabled = true,
        component_separators = '|',
        section_separators = { left = '', right = '' },
        disabled_filetypes = { 'packer', 'neo-tree', 'undotree', 'diffpanel' }
    }
}
