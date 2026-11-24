#!/bin/sh
# Personal assistant chat: a dedicated OpenCode server with its own config
# (~/.config/opencode-assistant) and session database. The server is detached
# from the popup, so closing the popup leaves running chats working.
set -eu
umask 077

PORT=4097
URL="http://127.0.0.1:$PORT"
STATE="$HOME/.local/state/opencode-assistant"
WORKSPACE="$HOME/.local/share/opencode-assistant"

export OPENCODE_CONFIG_DIR="$HOME/.config/opencode-assistant"
export OPENCODE_DB="$STATE/opencode.db"
[ -f "$HOME/.config/local/opencode/opencode.json" ] && export OPENCODE_CONFIG="$HOME/.config/local/opencode/opencode.json"

mkdir -p "$STATE" "$WORKSPACE"
[ -f "$STATE/password" ] || openssl rand -hex 24 > "$STATE/password"
PASSWORD=$(cat "$STATE/password")

# The password goes through curl's stdin, never its argv, which any local user can read with ps.
healthy() { printf 'user = "opencode:%s"\n' "$PASSWORD" | curl -sf -K - "$URL/api/info" >/dev/null; }

serve() (
  # Machine-local environment for the server only, e.g. provider credentials (AWS_PROFILE).
  [ -f "$HOME/.config/local/opencode/assistant.env" ] && . "$HOME/.config/local/opencode/assistant.env"
  cd "$WORKSPACE"
  # setsid puts the server in its own session so the popup's hangup does not reach it.
  OPENCODE_PASSWORD="$PASSWORD" exec perl -MPOSIX -e 'POSIX::setsid(); exec @ARGV' -- \
    opencode serve --hostname 127.0.0.1 --port "$PORT" >"$STATE/server.log" 2>&1 </dev/null
)

if ! healthy; then
  serve &
  tries=0
  until healthy; do
    tries=$((tries + 1))
    [ "$tries" -gt 100 ] && { echo "assistant server failed to start, see $STATE/server.log"; exit 1; }
    sleep 0.1
  done
fi

OPENCODE_PASSWORD="$PASSWORD" exec opencode --server "$URL" --continue "$WORKSPACE"
