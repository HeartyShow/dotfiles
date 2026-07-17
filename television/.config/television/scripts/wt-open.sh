#!/bin/sh
# wt-open: ensure worktree exists then open a tmux window with 3-pane layout
#
# Usage: wt-open <branch> [--create]
#
# Layout:
#   ┌──────────┬─────────────┐
#   │          │             │
#   │   nvim   │  opencode   │
#   │          │             │
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

# Get the worktree path
P=$(wt list --format=json | jq -r --arg b "$B" '.[] | select(.branch == $b) | .path')
if [ -z "$P" ]; then
  echo "Could not determine worktree path for branch: $B" >&2
  exit 1
fi

# Create window and capture its unique ID for reliable targeting
W=$(tmux new-window -n "$B" -c "$P" -P -F '#{window_id}')
tmux set-option -t "$W" -w automatic-rename off
NVIM=$(tmux display-message -p -t "$W.1" '#{pane_id}')
OPENCODE=$(tmux split-window -h -t "$NVIM" -c "$P" -l 50% -P -F '#{pane_id}')
tmux split-window -v -t "$NVIM" -c "$P" -l 25% >/dev/null
tmux send-keys -t "$NVIM" 'nvim' Enter
tmux send-keys -t "$OPENCODE" 'opencode' Enter
tmux select-pane -t "$NVIM"
