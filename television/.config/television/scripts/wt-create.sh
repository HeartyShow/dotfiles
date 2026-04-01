#!/bin/sh
# wt-create: prompt for new branch name, create from a base branch, open tmux window
#
# Usage: wt-create <base-branch>
#
# Prompts interactively for the new branch name, then creates a branch
# based on <base-branch> and opens it in a 3-pane tmux window.

BASE="$1"

if [ -z "$BASE" ]; then
  echo "Usage: wt-create <base-branch>" >&2
  exit 1
fi

printf "New branch (base: %s): " "$BASE"
read -r NAME

if [ -z "$NAME" ]; then
  exit 1
fi

wt switch --create --no-cd --base "$BASE" "$NAME" || exit 1

# Get the worktree path
P=$(wt list --format=json | jq -r --arg b "$NAME" '.[] | select(.branch == $b) | .path')
if [ -z "$P" ]; then
  echo "Could not determine worktree path for branch: $NAME" >&2
  exit 1
fi

# Create window with 3-pane layout (nvim zoomed)
W=$(tmux new-window -n "$NAME" -c "$P" -P -F '#{window_id}')
tmux set-option -t "$W" -w automatic-rename off
tmux split-window -h -t "$W" -c "$P" -l 40%
tmux split-window -v -t "$W.1" -c "$P" -l 25%
tmux send-keys -t "$W.1" 'nvim' Enter
tmux send-keys -t "$W.3" 'opencode' Enter
tmux select-pane -t "$W.1"
tmux resize-pane -Z -t "$W.1"
