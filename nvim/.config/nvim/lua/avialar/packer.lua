-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd.packadd('packer.nvim')

return require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    use 'mfussenegger/nvim-jdtls'

    -- Telescope
    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.3',
        requires = { { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope-project.nvim', 'nvim-telescope/telescope-live-grep-args.nvim' } }
    }
    use {
        'nvim-telescope/telescope-file-browser.nvim',
        requires = { 'nvim-telescope/telescope.nvim', 'nvim-lua/plenary.nvim' }
    }

    -- Treesitter
    use {
        'nvim-treesitter/nvim-treesitter',
        run = function()
            local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
            ts_update()
        end, }
    use('nvim-treesitter/playground')
    use('nvim-treesitter/nvim-treesitter-context');

    use({
        'stevearc/aerial.nvim',
        config = function()
            require('aerial').setup()
        end,
    })

    use {
        'ThePrimeagen/harpoon',
        branch = 'harpoon2',
        requires = { { 'nvim-lua/plenary.nvim' } }
    }
    use('theprimeagen/refactoring.nvim')
    use('mbbill/undotree')

    use 'nvim-tree/nvim-web-devicons'
    use 'lewis6991/gitsigns.nvim'

    use {
        'nvim-neo-tree/neo-tree.nvim',
        branch = 'v3.x',
        requires = {
            'nvim-lua/plenary.nvim',
            'nvim-tree/nvim-web-devicons',
            'MunifTanjim/nui.nvim',
        }
    }

    use('folke/zen-mode.nvim')
    use('github/copilot.vim')
    use('eandrju/cellular-automaton.nvim')
    use('laytan/cloak.nvim')

    use {
        'windwp/nvim-autopairs',
        config = function() require('nvim-autopairs').setup {} end
    }

    use {
        'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup()
        end
    }
    use('tpope/vim-surround')
    use('tpope/vim-repeat')

    use { 'catppuccin/nvim', as = 'catppuccin' }

    use({
        'iamcco/markdown-preview.nvim',
        run = 'cd app && npm install',
        setup = function()
            vim.g.mkdp_filetypes = {
                'markdown' }
        end,
        ft = { 'markdown' },
    })

    use({
        'kdheepak/lazygit.nvim',
        requires = {
            'nvim-lua/plenary.nvim',
        },
    })

    use { 'alexghergh/nvim-tmux-navigation' }
    use({
        'lukas-reineke/indent-blankline.nvim',
        config = function()
            require('ibl').setup { scope = { enabled = false } }
        end,
    })

    use {
        'goolord/alpha-nvim',
        requires = { 'nvim-tree/nvim-web-devicons' },
    }

    use { 'stevearc/dressing.nvim',
        config = function()
            require('dressing').setup({
                input = {
                    trim_prompt = true,
                    title_pos = 'center',
                }
            })
    end }

    use {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v3.x',
        requires = {
            -- LSP Support
            { 'neovim/nvim-lspconfig' },
            { 'williamboman/mason.nvim' },
            { 'williamboman/mason-lspconfig.nvim' },

            -- Autocompletion
            { 'hrsh7th/nvim-cmp' },
            { 'hrsh7th/cmp-buffer' },
            { 'hrsh7th/cmp-path' },
            { 'saadparwaiz1/cmp_luasnip' },
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'hrsh7th/cmp-nvim-lua' },

            -- Snippets
            { 'L3MON4D3/LuaSnip' },
            { 'rafamadriz/friendly-snippets' },

            -- Helper
            { 'hrsh7th/cmp-nvim-lsp-signature-help' },
        }
    }

    -- Prettier
    use('jose-elias-alvarez/null-ls.nvim')
    use('MunifTanjim/prettier.nvim')

    use('famiu/bufdelete.nvim')

    use { 'mistricky/codesnap.nvim', run = 'make'}

    use { 'asiryk/auto-hlsearch.nvim',
        config = function()
            require('auto-hlsearch').setup()
        end }

    use {
        'ahmedkhalf/project.nvim',
        config = function()
            require('project_nvim').setup {}
        end
    }

    use('ThePrimeagen/vim-be-good')
    use('nvim-lualine/lualine.nvim')
    use('m4xshen/smartcolumn.nvim')
end)
