---
description: Ask to review the changes in tuicr, then address my comments
---

Ask me to review the changes in tuicr, then act on my answer.

1. Pick the scope to review:
   - The changes made in this conversation: uncommitted only `-w`; commits only `-r <oldest>~1..<newest>`; both `-r <oldest>~1..HEAD -w`.
   - If this conversation made no changes, review the current branch: `-r <merge-base with origin's default branch>..HEAD`, plus `-w` if the tree is dirty.
   - State the chosen scope in one line.
2. Call the `tuicr_review` tool with the scope as `args` and a one-line `summary`. It returns once I answer, and if I chose to review, once I close tuicr.
   - If I answered not-now or auto-accept, follow what the result says and stop here.
3. Address the comments:
   - If it prints `NO TUICR SESSION` or no comments, say so and stop.
   - `issue`: fix it.
   - `suggestion`: weigh it; apply it if it is right, otherwise explain why not.
   - `question`, `note`, `none`: answer it; only change code if the answer implies a fix.
   - Ignore comments whose `author` is `opencode` unless I commented on the same lines.
4. End with one line per comment: `<location> — <done | skipped: reason | answer>`.
5. Once every comment has been addressed with actual changes, clear them with `tuicr review clearc --repo <Repo> --session <Session>`. Do not clear if you only planned or if any comment is still open.
