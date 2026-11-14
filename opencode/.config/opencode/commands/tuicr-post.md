---
description: Post the review findings from this conversation as tuicr comments
---

Post the review findings already settled in this conversation as comments in my tuicr session for this worktree, so I can triage them inside tuicr.

!`root=$(git rev-parse --show-toplevel); s=$(tuicr review list --repo "$root" | jq -r '[.[] | select(.kind == "local")] | sort_by(.updated_at) | last | .slug // empty'); echo "Repo: $root"; echo "Session: ${s:-NONE}"; echo "Current HEAD: $(git rev-parse --short HEAD)"`

Rules:
- If the session is `NONE` or its slug does not contain the current HEAD, stop and ask me to open tuicr first (tmux `prefix + t`) on the changes to review.
- Do not restart the review; use the findings from this conversation. Ask first if they are still unclear.
- One finding per comment, one `tuicr review add` call per comment:

```bash
tuicr review add --repo <Repo> --session <Session> --username opencode \
  --type <issue|suggestion|question|note> \
  --target-file <path> --line <n> [--end-line <n>] [--side new|old] \
  "<comment>"
```

- Type: `issue` for bugs and must-fix, `suggestion` for improvements, `question` when you need my input, `note` for context.
- Use `--side old` only for removed lines. Omit `--target-file` for review-level comments; omit `--line` for file-level comments.
- Comment style: start with the directive, then a short why. Keep it concise.
- End with the number of comments posted and remind me to reopen tuicr to see them.
