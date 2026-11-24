local lib = require("lib")

lib.popup_action("popup_gh_dash", "GitHub Dashboard (gh-dash)", { "gh-dash" }, 0.95, 0.9)
lib.popup_action("popup_tuicr", "Review Worktree Changes (tuicr)", { "tuicr" }, 0.95, 0.9)
lib.persistent_popup_action("popup_slack", "Slack (slk)", { "slk" }, 0.95, 0.9)
lib.persistent_popup_action("popup_assistant", "Assistant (OpenCode)", { "sh", lib.home .. "/.config/rex/scripts/assistant.sh" }, 0.95, 0.9)

rex.bind("ctrl+space>g", "popup_gh_dash")
rex.bind("ctrl+space>t", "popup_tuicr")
rex.bind("ctrl+space>s", "popup_slack")
rex.bind("ctrl+space>a", "popup_assistant")
