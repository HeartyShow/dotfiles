#!/bin/sh
# Personal assistant chat: a dedicated OpenCode server with its own config
# (~/.config/opencode-assistant) and session database. The server is detached
# from the popup, so closing the popup leaves running chats working.
set -eu

PORT=4097
URL="http://127.0.0.1:$PORT"
STATE="$HOME/.local/state/opencode-assistant"
WORKSPACE="$HOME/.local/share/opencode-assistant"

export OPENCODE_CONFIG_DIR="$HOME/.config/opencode-assistant"
export OPENCODE_DB="$STATE/opencode.db"
[ -f "$HOME/.config/local/opencode/opencode.json" ] && export OPENCODE_CONFIG="$HOME/.config/local/opencode/opencode.json"
# Machine-local environment for the server, e.g. provider credentials (AWS_PROFILE).
[ -f "$HOME/.config/local/opencode/assistant.env" ] && . "$HOME/.config/local/opencode/assistant.env"

mkdir -p "$STATE" "$WORKSPACE"
[ -f "$STATE/password" ] || (umask 077 && openssl rand -hex 24 > "$STATE/password")
OPENCODE_PASSWORD=$(cat "$STATE/password")
export OPENCODE_PASSWORD

healthy() { curl -sf -u "opencode:$OPENCODE_PASSWORD" "$URL/api/info" >/dev/null; }

if ! healthy; then
  cd "$WORKSPACE"
  # setsid puts the server in its own session so the popup's hangup does not reach it.
  perl -MPOSIX -e 'POSIX::setsid(); exec @ARGV' -- \
    opencode serve --hostname 127.0.0.1 --port "$PORT" >"$STATE/server.log" 2>&1 </dev/null &
  tries=0
  until healthy; do
    tries=$((tries + 1))
    [ "$tries" -gt 100 ] && { echo "assistant server failed to start, see $STATE/server.log"; exit 1; }
    sleep 0.1
  done
fi

exec opencode --server "$URL" --continue "$WORKSPACE"
