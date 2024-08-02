return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
        options = {
            theme = "auto",
            icons_enabled = true,
            component_separators = '|',
            section_separators = { left = '', right = '' },
            disabled_filetypes = { 'packer', 'neo-tree', 'undotree', 'diffpanel' }
        }
    },
    config = function(_, opts)
        require('lualine').setup(opts)
    end

}
