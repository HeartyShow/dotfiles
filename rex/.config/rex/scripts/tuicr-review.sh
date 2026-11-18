#!/bin/sh
# Opens tuicr in a floating layer with the given tuicr args, waits for it to close,
# then prints the review comments.
set -eu

rex() { "$REX_BIN_DIR/rex" -S "$REX_SERVER" "$@"; }

root=$(git rev-parse --show-toplevel)
block=$(rex do -s "$REX_SESSION" --json popup_tuicr cwd="$root" args="$*" | jq -r '.block_ids[0]')

while rex block ls -s "$REX_SESSION" -q --short=false | grep -qxF "$block"; do
  sleep 1
done

slug=$(tuicr review list --repo "$root" | jq -r '[.[] | select(.kind == "local")] | sort_by(.updated_at) | last | .slug // empty')
if [ -z "$slug" ]; then
  echo "NO TUICR SESSION"
  exit 0
fi

echo "Repo: $root"
echo "Session: $slug"
echo "Current HEAD: $(git rev-parse --short HEAD)"
tuicr review comments --repo "$root" --session "$slug" | jq '[.[] | {location, comment_type, author, content}]'
