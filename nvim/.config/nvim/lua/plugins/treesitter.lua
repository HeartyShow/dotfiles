return {
    'nvim-treesitter/nvim-treesitter',
    build = function()
        local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
        ts_update()
    end,
    dependencies = {
        'nvim-treesitter/playground',
        'nvim-treesitter/nvim-treesitter-context',
    },
    opts = {
        -- A list of parser names, or "all"
        ensure_installed = { "vimdoc", "javascript", "java", "typescript", "c", "python", "lua", "rust" },

        -- Install parsers synchronously (only applied to `ensure_installed`)
        sync_install = false,

        -- Automatically install missing parsers when entering buffer
        -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
        auto_install = true,

        highlight = {
            -- `false` will disable the whole extension
            enable = true,

            -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
            -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
            -- Using this option may slow down your editor, and you may see some duplicate highlights.
            -- Instead of true it can also be a list of languages
            additional_vim_regex_highlighting = false,
        },
    },
    config = function(_, opts)
        require("nvim-treesitter.configs").setup(opts)
        local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
        parser_config.cds = {
            install_info = {
                -- local path or git repo
                -- url = "~/apps/tree-sitter-cds",
                url = "~/apps/tree-sitter-cds",
                files = { "src/parser.c", "src/scanner.c" }
            },
            filetype = "cds",
            -- additional filetypes that use this parser
            used_by = { "cdl", "hdbcds" }
        }
    end
}
