return {
    'anuvyklack/help-vsplit.nvim',
    opts = {
        side = 'left',
    },
    config = function(_, opts)
        require('help-vsplit').setup(opts)
    end
}
