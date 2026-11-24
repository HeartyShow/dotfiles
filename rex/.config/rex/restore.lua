-- rexurrect brings sessions and their programs back once per server start.
do
  local r = rex.exec({ "/run/current-system/sw/bin/rexurrect", "auto-restore" }, {
    env = {
      REXURRECT_STATE_DIR = os.getenv("HOME") .. "/.local/state/rexurrect",
      REXURRECT_CONFIG = os.getenv("HOME") .. "/.config/rexurrect/config.toml",
    },
  })
  if r then io.stderr:write(r.stderr) end
end
