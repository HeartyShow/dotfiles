---
description: Review a GitHub pull request by number with optional quoted focus
agent: review
subtask: true
---

Review the following pull request:

- PR number: `$1`
- Extra review focus: `$2`
- Treat the extra focus as optional guidance only; do not narrow the review beyond normal bug, risk, and security checks.
- Order the review items by Critical, High, Medium, Low, Other sections
- Also number every item to be easily addressable later (1. 2. etc.)

**PR metadata:**
```
!`gh pr view $1 --json title,body,author,baseRefName,headRefName,labels,additions,deletions,changedFiles`
```

**Diff:**
```
!`gh pr diff $1`
```
