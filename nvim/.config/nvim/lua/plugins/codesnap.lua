return {
  enabled = false,
  "mistricky/codesnap.nvim",
  build = "make build_generator",
  opts = {
    has_breadcrumbs = true,
    bg_theme = "dusk",
    watermark = "",
    code_font_family = "JetBrainsMono Nerd Font Mono",
    bg_x_padding = 30,
    bg_y_padding = 30,
  },
}
