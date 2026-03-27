#!/bin/sh
# wt-open: ensure worktree exists then open a tmux window with 3-pane layout
#
# Usage: wt-open <branch> [--create]
#
# Layout (nvim zoomed on entry):
#   ┌──────────┬─────────────┐
#   │          │             │
#   │   nvim   │  opencode   │
#   │ (zoomed) │             │
#   ├──────────┤             │
#   │ terminal │             │
#   └──────────┴─────────────┘

B="$1"
CREATE="$2"

if [ -z "$B" ]; then
  echo "Usage: wt-open <branch> [--create]" >&2
  exit 1
fi

# Ensure worktree exists
if [ "$CREATE" = "--create" ]; then
  wt switch --create --no-cd "$B" || exit 1
else
  wt switch --no-cd "$B" || exit 1
fi

# If a tmux window with this name already exists, we're done
# (post-start hook or previous invocation already created it)
tmux list-windows -F '#W' | grep -qx "$B" && exit 0

# Get the worktree path
P=$(wt list --format=json | jq -r --arg b "$B" '.[] | select(.branch == $b) | .path')
if [ -z "$P" ]; then
  echo "Could not determine worktree path for branch: $B" >&2
  exit 1
fi

# Create window with 3-pane layout
tmux new-window -n "$B" -c "$P"
tmux split-window -h -t "$B" -c "$P" -l 40%
tmux split-window -v -t "$B.1" -c "$P" -l 25%
tmux send-keys -t "$B.1" 'nvim' Enter
tmux send-keys -t "$B.3" 'opencode' Enter
tmux select-pane -t "$B.1"
tmux resize-pane -Z -t "$B.1"
