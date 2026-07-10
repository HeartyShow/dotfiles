---
description: Draft a pending GitHub PR review from the current discussion
---

Draft a **pending** GitHub PR review based on the **current conversation context**.

This command is meant to be used **after** the review phase, once the findings and wording have already been discussed and settled with the user.

Requirements:
- Stay in the current/main agent context. Do not restart the review from scratch unless precise comment placement is still missing.
- Use the findings already established in this conversation.
- Use the `gh` CLI.
- Use the pull request associated with the current branch.
- Create the comments inside a **pending review draft**, not as individual standalone comments, and do **not** submit the review.
- Put comments inline at the correct locations in the changed code when a specific code location is part of the point.
- If a point is not tied to a single line, include it in the pending review body or place it at the closest relevant line.
- Keep comments direct, clear, and concise.
- Prefer one actionable point per comment.
- Use short markdown code snippets only when they make the requested change clearer.
- Do not use heavy report formatting.
- Do not post anything if the final points are still unclear; ask first.
- Return the pending review URL at the end.

Suggested workflow:
1. Determine the target PR and its head SHA using `gh pr view` for the current branch.
2. Translate the settled findings from this conversation into PR comments.
3. Create a pending review with `gh api` against the pull request reviews endpoint, without setting a final review event.
4. Return the pending review URL so the user can inspect and submit it manually.

Comment style:
- Start with the directive.
- Then explain briefly why the change is needed.
- Mention concrete implementation direction when useful.
- Keep the tone simple and decisive.
- Example style:
  - `Don't use Promise.all here.`
  - `Please don't log whole payloads or request objects.`
  - `This class does not belong in model/.`
- It can still get longer of course if the action is particularly heavy or needs more details to understand.
- If helpful, use a short snippet like:

```ts
await Promise.allSettled([...])
```

or

```java
public boolean isPermanent()
```

Only include snippets when they make the requested change more obvious.
