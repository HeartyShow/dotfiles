---
description: Review a GitHub pull request by number
agent: review
subtask: true
---

Review the following pull request:

**PR metadata:**
```
$!gh pr view $1 --json title,body,author,baseRefName,headRefName,labels,additions,deletions,changedFiles
```

**Diff:**
```
$!gh pr diff $1
```
