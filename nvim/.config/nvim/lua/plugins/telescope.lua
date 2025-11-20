return {
  "nvim-telescope/telescope.nvim",
  opts = function(_, opts)
    opts.defaults = {
      path_display = function(_, path)
        local tail = require("telescope.utils").path_tail(path)
        local parent = path:sub(1, #path - #tail)
        local smart_parent = require("telescope.utils").path_smart(parent)
        local display = smart_parent .. tail

        local highlights = {
          {
            {
              0, -- highlight start position
              #smart_parent, -- highlight end position
            },
            "Comment", -- highlight group name
          },
        }

        return display, highlights
      end,
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
