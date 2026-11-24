import { spawn } from "node:child_process"
import { homedir } from "node:os"
import { join } from "node:path"
import { Plugin } from "@opencode/plugin"
import { TuicrReview } from "./rpc.js"

const SCRIPT = join(homedir(), ".config/rex/scripts/tuicr-review.sh")

const CLOSED = {
  "not-now": "The user answered Not now to the review request: they do not want a review process right now. This is not an approval of the changes; decide from the context what to do next.",
  "auto-accept": "The user answered Auto-accept to the review request: they trust the code under review. Proceed as if it had been reviewed and approved.",
}

// Each location loads its own plugin instance, and the TUI may answer through another location than the tool call's.
const requests = (globalThis[Symbol.for("tuicr-review.requests")] ??= new Map())

function run(args, cwd, rexSession, signal) {
  return new Promise((resolve) => {
    const child = spawn("sh", [SCRIPT, ...args], {
      cwd,
      env: { ...process.env, REX_SESSION: rexSession },
      signal,
    })
    let stdout = ""
    let stderr = ""
    child.stdout.on("data", (chunk) => (stdout += chunk))
    child.stderr.on("data", (chunk) => (stderr += chunk))
    child.on("error", (error) => resolve(`tuicr review failed: ${error.message}`))
    child.on("close", (code) => resolve(code === 0 ? stdout : `tuicr review failed (exit ${code}):\n${stderr}${stdout}`))
  })
}

export default Plugin.define({
  id: "tuicr-review",
  async setup(ctx) {
    const registration = await ctx.rpc.register(TuicrReview, {
      pending: async () => ({ requests: [...requests.values()].map((entry) => entry.request) }),
      answer: async ({ requestID, decision, rexSession }) => {
        const entry = requests.get(requestID)
        if (!entry || (decision === "open" && !rexSession)) return { accepted: false }
        requests.delete(requestID)
        entry.resolve({ decision, rexSession })
        return { accepted: true }
      },
    })

    await ctx.tool.transform((editor) => {
      editor.add({
        name: "tuicr_review",
        description: [
          "Ask the user to review changes in tuicr. Shows them a prompt in their OpenCode TUI and their Rex activity inbox,",
          "then waits for one of three answers:",
          "- open: tuicr opens on `args` in a Rex popup; returns the review comments once they close it.",
          "- not-now: they do not want a review process right now (not an approval).",
          "- auto-accept: no review needed, they trust the code.",
          "Call it whenever you want a review, for example before publishing or updating a PR.",
        ].join("\n"),
        input: {
          type: "object",
          properties: {
            args: {
              type: "array",
              items: { type: "string" },
              description: 'tuicr arguments selecting the changes, e.g. ["-w"] or ["-r", "abc123~1..HEAD", "-w"]',
            },
            summary: { type: "string", description: "One line describing what is up for review" },
          },
          required: ["args", "summary"],
          additionalProperties: false,
        },
        options: { codemode: false },
        execute: async ({ args, summary }, context) => {
          const { signal, sessionID } = context
          const session = await ctx.session.get({ sessionID })
          const request = { requestID: context.id, sessionID, args, summary }
          const answer = new Promise((resolve) => {
            requests.set(request.requestID, { request, resolve })
            signal.addEventListener("abort", () => resolve(undefined), { once: true })
          })

          await context.progress({ status: "Waiting for your review decision" })
          await registration.events.emit("requested", request)
          const result = await answer
          requests.delete(request.requestID)
          await registration.events.emit("settled", { requestID: request.requestID, sessionID })

          if (!result) return { content: "The review request was cancelled." }
          if (result.decision !== "open") return { content: CLOSED[result.decision] }
          await context.progress({ status: "Reviewing in tuicr" })
          return { content: await run(args, session.location.directory, result.rexSession, signal) }
        },
      })
    })
  },
})
