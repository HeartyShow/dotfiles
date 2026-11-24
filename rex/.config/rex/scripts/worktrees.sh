#!/bin/sh
# Builds a worktree from origin's default branch, then opens it as a background Rex tab.
# Started by the worktree picker in its own tab, inside the repo.
#
# Usage: worktrees.sh <name>

set -eu

name="$1"
container="$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")"
base="$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||')"
base="${base:-main}"

# worktree-path override keeps the folder named exactly as typed (no sanitize_db).
git fetch origin "$base" &&
  wt switch --create --yes --no-cd --base "origin/$base" --config-set "worktree-path=\"$container/$name\"" "$name" &&
  "$REX_BIN_DIR/rex" do open_worktree path="$container/$name" background=true ||
  { printf 'Creating worktree %s failed.\nPress Enter to close.' "$name"; read -r _; exit 1; }
