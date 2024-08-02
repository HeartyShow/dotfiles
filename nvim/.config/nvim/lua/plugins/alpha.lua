return {
    'goolord/alpha-nvim',
    dependencies = {
        'nvim-tree/nvim-web-devicons',
        'nvim-telescope/telescope.nvim',
    },
    opts = function()
        local dashboard = require("alpha.themes.dashboard")
        -- Set header
        dashboard.section.header.val = {
            "                                                     ",
            "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
            "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
            "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
            "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
            "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
            "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
            "                                                     ",
        }

        -- Set menu
        dashboard.section.buttons.val = {
            dashboard.button("r", "󱦟  Recent", ":Telescope oldfiles<CR>"),
            dashboard.button("p", "󰝰  Projects",
                ":lua require'telescope'.extensions.project.project{display_type = 'full'}<CR>"),
            dashboard.button("e", "󰝒  New file", ":ene <BAR> startinsert <CR>"),
            dashboard.button("l", "󰏗  Lazy", ":Lazy<CR>"),
            dashboard.button("s", "  Settings", ":e $NVIM_DIR<CR>"),
            dashboard.button("q", "󰗼  Quit NVIM", ":qa<CR>"),
        }
        return dashboard.opts
    end,
    config = function(_, opts)
        require("alpha").setup(opts)
    end
}
