return {
  "snacks.nvim",
  opts = {
    gh = { enabled = true },
    git = { enabled = true },
    gitbrowse = { enabled = true },
    picker = {
      enabled = true,
      sources = {
        files = {
          hidden = true,
          config = function(opts)
            local root = Snacks.git.get_root()
            if root then
              opts.cwd = root
            end
            return opts
          end,
        },
        grep = {
          hidden = true,
          config = function(opts)
            local root = Snacks.git.get_root()
            if root then
              opts.cwd = root
            end
            return opts
          end,
        },
        explorer = { hidden = true },
        gh_issue = {},
        gh_pr = {},
      },
      win = {
        input = {
          keys = {
            ["<c-j>"] = { "preview_scroll_down", mode = { "i", "n" } },
            ["<c-k>"] = { "preview_scroll_up", mode = { "i", "n" } },
          },
        },
        list = {
          keys = {
            ["<c-j>"] = "preview_scroll_down",
            ["<c-k>"] = "preview_scroll_up",
          },
        },
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
