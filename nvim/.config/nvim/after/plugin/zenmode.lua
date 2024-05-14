local zen = require("zen-mode")

zen.setup {
    window = {
        options = {
        },
        width = 0.8,
        height = 1
    },
    plugins = {
        gitsigns = {
            enabled = false
        },
        tmux = {
            enabled = false
        }
    }
}

vim.keymap.set("n", "<leader>zz", function()
    zen.toggle()
    vim.wo.wrap = false
    vim.wo.number = true
    vim.wo.rnu = true
end)
