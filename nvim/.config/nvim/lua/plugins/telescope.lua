return {
  "nvim-telescope/telescope.nvim",
  opts = function(_, opts)
    opts.defaults = {
      path_display = {
        smart = true,
      },
      sorting_strategy = "ascending",
      prompt_prefix = " ",
      selection_caret = " ",
      entry_prefix = "  ",
      layout_config = {
        horizontal = {
          prompt_position = "top",
          preview_width = 0.65,
          results_width = 0.8,
        },
        vertical = {
          mirror = false,
        },
        width = 0.87,
        height = 0.80,
        preview_cutoff = 120,
      },
    }
  end,
}
