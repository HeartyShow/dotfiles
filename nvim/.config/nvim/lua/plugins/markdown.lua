return {
  -- Disable markdownlint diagnostics (no more line-length / style warnings)
  {
    "nvimtools/none-ls.nvim",
    opts = function(_, opts)
      opts.sources = vim.tbl_filter(function(source)
        return source.name ~= "markdownlint-cli2"
      end, opts.sources or {})
    end,
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        markdown = {},
        mdx = {},
      },
    },
  },

  -- Customize in-buffer rendering
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      file_types = { "markdown", "mdx", "markdown.mdx" },
      code = {
        language_border = " ",
        language_left = "",
        language_right = "",
        sign = true,
        style = "block",
      },
      checkbox = {
        enabled = true,
      },
      heading = {
        border = true,
        left_pad = 2,
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
        position = "inline",
        right_pad = 2,
        width = "block",
      },
      pipe_table = {
        preset = "round",
      },
      render_modes = true,
      sign = {
        enabled = false,
      },
    },
  },

  -- Auto-continue lists / checkboxes on Enter
  {
    "gaoDean/autolist.nvim",
    ft = { "markdown", "mdx" },
    opts = {},
    keys = {
      { "<CR>", "<CR><cmd>AutolistNewBullet<cr>", mode = "i" },
      { "o", "o<cmd>AutolistNewBullet<cr>" },
      { "O", "O<cmd>AutolistNewBulletBefore<cr>" },
      { "<Tab>", "<cmd>AutolistTab<cr>", mode = "i" },
      { "<S-Tab>", "<cmd>AutolistShiftTab<cr>", mode = "i" },
      { "<leader>x", "<cmd>AutolistToggleCheckbox<cr><CR>" },
    },
  },
}
