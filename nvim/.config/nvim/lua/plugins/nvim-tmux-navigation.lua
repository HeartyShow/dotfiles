return {
  "alexghergh/nvim-tmux-navigation",
  keys = {
    {
      "<C-h>",
      function()
        require("nvim-tmux-navigation").NvimTmuxNavigateLeft()
      end,
      mode = "n",
    },
    {
      "<C-j>",
      function()
        require("nvim-tmux-navigation").NvimTmuxNavigateDown()
      end,
      mode = "n",
    },
    {
      "<C-k>",
      function()
        require("nvim-tmux-navigation").NvimTmuxNavigateUp()
      end,
      mode = "n",
    },
    {
      "<C-l>",
      function()
        require("nvim-tmux-navigation").NvimTmuxNavigateRight()
      end,
      mode = "n",
    },
    {
      "<C-\\>",
      function()
        require("nvim-tmux-navigation").NvimTmuxNavigateLastActive()
      end,
      mode = "n",
    },
    {
      "<C-Space>",
      function()
        require("nvim-tmux-navigation").NvimTmuxNavigateNext()
      end,
      mode = "n",
    },
  },
}
