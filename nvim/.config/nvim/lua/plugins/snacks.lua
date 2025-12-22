return {
  "snacks.nvim",
  opts = {
    gh = { enabled = true },
    git = { enabled = true },
    gitbrowse = { enabled = true },
    picker = {
      enabled = true,
      sources = {
        gh_issue = {},
        gh_pr = {},
      },
      layout = { default = { layout = { win = "preview", title = "hello {preview}" } } },
    },
    words = { enabled = false, notify_end = false, debounce = 0 },
  },
  keys = {
    {
      "<leader>gi",
      function()
        Snacks.picker.gh_issue()
      end,
      desc = "GitHub Issues (open)",
    },
    {
      "<leader>gI",
      function()
        Snacks.picker.gh_issue({ state = "all" })
      end,
      desc = "GitHub Issues (all)",
    },
    {
      "<leader>gp",
      function()
        Snacks.picker.gh_pr()
      end,
      desc = "GitHub Pull Requests (open)",
    },
    {
      "<leader>gP",
      function()
        Snacks.picker.gh_pr({ state = "all" })
      end,
      desc = "GitHub Pull Requests (all)",
    },
    {
      "<leader>go",
      function()
        Snacks.gitbrowse.open()
      end,
      desc = "Open Git Repository in Browser",
    },
  },
}
