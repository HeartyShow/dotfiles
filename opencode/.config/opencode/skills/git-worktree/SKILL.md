---
name: git-worktree
description: Working with git worktrees in bare-clone repos managed by worktrunk (wt)
---

# Git Worktree Workflow

This user uses bare-clone repos with git worktrees via `worktrunk` (wt).

## Key concepts
- Repos are bare clones. Worktrees are checked out inside the bare repo directory.
- The `.git` is at the repo root level, NOT inside the worktree.
- Use `wt switch <branch>` to create/switch worktrees, NOT `git checkout`.
- Use `wt list` to see existing worktrees.
- The `clone()` shell function creates new bare-clone repos.

## Rules
- NEVER run `git checkout` to switch branches -- use `wt switch`.
- NEVER run `git clone` normally -- use the `clone()` function.
- When navigating, the project root for code is the worktree dir, not the bare repo dir.
- `git status`, `git diff`, `git add`, `git commit` etc. work normally inside a worktree.
- To create a new branch and worktree: `wt switch <new-branch>`.
- To delete a worktree: `wt remove <branch>`.
