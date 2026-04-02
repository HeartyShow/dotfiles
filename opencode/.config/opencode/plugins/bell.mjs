import { openSync, writeSync, closeSync } from "node:fs"

export default async () => {
  const debounceMs = 1200
  const last = new Map()

  const ring = (key) => {
    const now = Date.now()
    const prev = last.get(key) || 0
    if (now - prev < debounceMs) return
    last.set(key, now)
    try {
      const fd = openSync("/dev/tty", "w")
      writeSync(fd, "\x07")
      closeSync(fd)
    } catch {}
  }

  return {
    event: async ({ event }) => {
      const type = event?.type
      const sid = event?.properties?.sessionID
      if (type === "permission.asked") ring(sid ? `perm:${sid}` : "perm")
      if (type === "question.asked") ring(sid ? `ques:${sid}` : "ques")
      if (type === "session.idle") ring(sid ? `idle:${sid}` : "idle")
      if (type === "session.error") ring(sid ? `err:${sid}` : "err")
    },
  }
}
