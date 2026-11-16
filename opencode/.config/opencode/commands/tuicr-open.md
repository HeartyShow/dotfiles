---
description: Open tuicr in a Rex popup on the changes to review, then address my comments
---

Open tuicr so I can review, wait for me to close it, then address my comments.

1. Pick the scope to review:
   - The changes made in this conversation: uncommitted only `-w`; commits only `-r <oldest>~1..<newest>`; both `-r <oldest>~1..HEAD -w`.
   - If this conversation made no changes, review the current branch: `-r <merge-base with origin's default branch>..HEAD`, plus `-w` if the tree is dirty.
   - State the chosen scope in one line.
2. Run `sh ~/.config/rex/scripts/tuicr-review.sh <scope>` with no timeout. It returns once I close tuicr and prints my comments.
3. Address the comments:
   - If it prints `NO TUICR SESSION` or no comments, say so and stop.
   - `issue`: fix it.
   - `suggestion`: weigh it; apply it if it is right, otherwise explain why not.
   - `question`, `note`, `none`: answer it; only change code if the answer implies a fix.
   - Ignore comments whose `author` is `opencode` unless I commented on the same lines.
4. End with one line per comment: `<location> — <done | skipped: reason | answer>`.
5. Once every comment has been addressed with actual changes, clear them with `tuicr review clearc --repo <Repo> --session <Session>`. Do not clear if you only planned or if any comment is still open.
