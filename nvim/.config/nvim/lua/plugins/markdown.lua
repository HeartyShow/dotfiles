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
      },
    },
  },

  -- Customize in-buffer rendering
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
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
}
