#!/bin/sh
# Rex worktree picker. Runs inside a floating layer in the focused pane's repo.
# Enter opens the chosen worktree as a Rex tab. Ctrl+T, or Enter on a name that
# matches no worktree, creates one from origin's default branch in a background tab.
#
# Usage: worktrees.sh pick | list | build <name>

set -eu

rex() { "$REX_BIN_DIR/rex" -S "$REX_SERVER" "$@"; }

worktree_paths() {
  git worktree list --porcelain | awk '
    /^worktree /{p=substr($0,10)}
    /^bare$/{p=""}
    /^$/{if(p)print p; p=""}
    END{if(p)print p}'
}

path_of() {
  worktree_paths | awk -F/ -v n="$1" '$NF==n{print; found=1} END{exit !found}'
}

container() {
  dirname "$(git rev-parse --path-format=absolute --git-common-dir)"
}

pause() {
  printf '%s\nPress Enter to close.' "$1"
  read -r _
}

list() {
  worktree_paths | awk -F/ '{print $NF}'
}

create() {
  printf 'New worktree name%s: ' "${1:+ [$1]}"
  read -r name
  name="${name:-$1}"
  [ -n "$name" ] || exit 0
  if path_of "$name" >/dev/null; then
    pause "Worktree $name already exists."
    exit 1
  fi
  rex run -s "$REX_SESSION" --focus=false --label "$name (creating)" -c "$PWD" -- sh "$0" build "$name" >/dev/null
}

build() {
  base="$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||')"
  base="${base:-main}"
  # worktree-path override keeps the folder named exactly as typed (no sanitize_db).
  git fetch origin "$base" &&
    wt switch --create --yes --no-cd --base "origin/$base" --config-set "worktree-path=\"$(container)/$1\"" "$1" &&
    rex do -s "$REX_SESSION" open_worktree path="$(container)/$1" background=true ||
    { pause "Creating worktree $1 failed."; exit 1; }
}

pick() {
  out="$(tv --no-preview --expect ctrl-t --source-command "sh '$0' list" --source-output '{}')" || exit 0
  selected="$(printf '%s\n' "$out" | tail -n 1)"
  if [ "$(printf '%s\n' "$out" | head -n 1)" = ctrl-t ]; then
    create ""
  elif path="$(path_of "$selected")"; then
    rex do -s "$REX_SESSION" open_worktree path="$path" background=false
  elif [ -n "$selected" ]; then
    create "$selected"
  fi
}

case "${1:-}" in
  pick) pick ;;
  list) list ;;
  build) build "$2" ;;
  *) echo "usage: $0 pick|list|build <name>" >&2; exit 2 ;;
esac
