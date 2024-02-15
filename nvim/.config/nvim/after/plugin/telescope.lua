local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader>/', function()
    -- You can pass additional configuration to telescope to change theme, layout, etc.
    require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        previewer = false,
    })
end, { desc = '[/] Fuzzily search in current buffer' })

require("telescope").load_extension "file_browser"

vim.api.nvim_set_keymap(
    "n",
    "<space>fb",
    ":Telescope file_browser<CR>",
    { noremap = true }
)

vim.keymap.set('n', '<leader>fs', builtin.find_files, {})

vim.keymap.set('n', '<c-p>', function()
    builtin.git_files({ show_untracked = true })
end)
vim.keymap.set('n', '<leader>ps', function()
    builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)
vim.keymap.set('n', '<leader>vh', builtin.help_tags, {})

require("telescope").load_extension("aerial")
vim.keymap.set('n', '<leader>o', ':Telescope aerial<CR>')

require("telescope").setup({
    defaults = {
        path_display = {
            smart = true
        }
    }
})
