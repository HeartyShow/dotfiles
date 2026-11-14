---
description: Address my tuicr review comments for the current worktree
---

Address the review comments I left in tuicr for this worktree.

!`root=$(git rev-parse --show-toplevel); s=$(tuicr review list --repo "$root" | jq -r '[.[] | select(.kind == "local" and .comment_count > 0)] | sort_by(.updated_at) | last | .slug // empty'); if [ -z "$s" ]; then echo "NO TUICR SESSION WITH COMMENTS"; else echo "Repo: $root"; echo "Session: $s"; echo "Current HEAD: $(git rev-parse --short HEAD)"; echo; tuicr review comments --repo "$root" --session "$s"; fi`

Rules:
- If there is no session, say so and stop.
- If the session slug does not contain the current HEAD, warn me that the comments were made on an older commit and line numbers may have moved, then continue.
- Handle each comment by `comment_type`:
  - `issue`: fix it.
  - `suggestion`: weigh it; apply it if it is right, otherwise explain why not.
  - `question`, `note`, `none`: answer it; only change code if the answer implies a fix.
- Ignore comments whose `author` is `opencode` unless I commented on the same lines.
- End with one line per comment: `<location> — <done | skipped: reason | answer>`.
- Once every comment has been addressed with actual changes, clear them with `tuicr review clearc --repo <Repo> --session <Session>`. Do not clear if you only planned or if any comment is still open.
