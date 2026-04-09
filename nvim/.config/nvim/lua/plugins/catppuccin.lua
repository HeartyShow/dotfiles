return {
  "catppuccin/nvim",
  opts = {
    custom_highlights = function(colors)
      return {
        CopilotChatHeader = { fg = colors.mauve, bold = true },
        CopilotChatSeparator = { fg = colors.mauve, bold = true },
        CopilotChatResource = { fg = colors.teal, italic = true },
        CopilotChatStatus = { fg = colors.teal, bold = true },
      }
    end,
  },
}
