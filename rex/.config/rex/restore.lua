local lib = require("lib")

-- rexurrect brings sessions and their programs back once per server start.
local result = rex.exec({ "rexurrect", "auto-restore" }, {
  env = { PATH = lib.path .. ":" .. (os.getenv("PATH") or "") },
  timeout = 30,
})
if result then io.stderr:write(result.stderr) end
