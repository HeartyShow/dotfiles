#!/bin/sh
# Rex session picker, a sesh replacement without tmux. Lists Rex sessions, sesh's
# configured sessions and zoxide directories. Enter switches to a Rex session or
# creates one named after the directory, in that directory.
#
# Usage: sessions.sh pick | list [plain]

set -eu

rex() { "$REX_BIN_DIR/rex" -S "$REX_SERVER" "$@"; }

# One TSV line per entry: kind, name, path. Same order as list.
entries() {
  {
    rex api call session.list | jq -r '.sessions[] | ["session", .label, ""] | @tsv'
    sesh list -j -c | jq -r '.[] | ["config", .Name, .Path] | @tsv'
    sesh list -j -z | jq -r '.[] | ["zoxide", (.Path | split("/") | last), .Path] | @tsv'
  } | awk -F'\t' '$1 == "zoxide" && seen[$3]++ { next } $1 == "config" { seen[$3] = 1 } { print }'
}

# Same icons and colors as `sesh list --icons`; zoxide entries show their path.
list() {
  entries | awk -F'\t' -v plain="${1:-}" -v home="$HOME" '
    BEGIN {
      icon["session"] = "\356\257\210"; color["session"] = 34
      icon["config"] = "\356\230\225"; color["config"] = 90
      icon["zoxide"] = "\357\204\224"; color["zoxide"] = 36
    }
    { label = $1 == "zoxide" ? $3 : $2
      if (index(label, home) == 1) label = "~" substr(label, length(home) + 1)
      if (plain) printf "%s %s\n", icon[$1], label
      else printf "\033[%dm%s\033[39m %s\n", color[$1], icon[$1], label }'
}

open_entry() {
  name="$(printf '%s' "$1" | cut -f2)"
  path="$(printf '%s' "$1" | cut -f3)"
  rex do -s "$REX_SESSION" open_session name="$name" path="$path"
}

pick() {
  selected="$(tv --no-preview --ansi --source-command "sh '$0' list" --source-output '{strip_ansi}')" || exit 0
  [ -n "$selected" ] || exit 0
  index="$(list plain | grep -nxF -- "$selected" | cut -d: -f1 | head -n 1)"
  [ -n "$index" ] || exit 0
  open_entry "$(entries | sed -n "${index}p")"
}

case "${1:-}" in
  pick) pick ;;
  list) list "${2:-}" ;;
  *) echo "usage: $0 pick|list [plain]" >&2; exit 2 ;;
esac
