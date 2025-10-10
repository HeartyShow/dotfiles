return {
  "CopilotC-Nvim/CopilotChat.nvim",
  opts = function(_, opts)
    local user = vim.env.USER or "User"
    user = user:sub(1, 1):upper() .. user:sub(2)
    opts.model = "gemini-2.5-pro"
    opts.resources = { "buffer", "selection" }
    opts.window = {
      width = 0.35,
    }
    opts.headers = {
      user = " " .. user .. " ",
      assistant = " Copilot ",
    }
    opts.show_help = false
    opts.insert_at_end = true
  end,
}
