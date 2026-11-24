import { createHash } from "node:crypto"
import { For } from "solid-js"
import { TextAttributes } from "@opentui/core"
import { Plugin, usePlugin } from "@opencode/plugin/tui"
import { TuicrReview } from "./rpc.js"

const ACTIONS = [
  { title: "Open", key: "enter", bind: "return", value: "open" },
  { title: "Not now", key: "n", bind: "n", value: "not-now" },
  { title: "Auto-accept", key: "a", bind: "a", value: "auto-accept" },
] as const

type Decision = (typeof ACTIONS)[number]["value"]
type Request = { requestID: string; sessionID: string; args: string[]; summary: string }

const clip = (text: string, length: number) => (text.length > length ? `${text.slice(0, length - 1)}…` : text)
const statusID = (requestID: string) => `rev_${createHash("sha256").update(requestID).digest("hex").slice(0, 16)}`

function Prompt(props: { request: Request; onPick: (decision: Decision) => void }) {
  const context = usePlugin()
  const theme = context.theme

  context.keymap.layer(() => ({
    mode: "modal",
    commands: ACTIONS.map((action) => ({ bind: action.bind, run: () => props.onPick(action.value) })),
  }))

  return (
    <box paddingLeft={2} paddingRight={2} paddingBottom={1} gap={1}>
      <text fg={theme.text.base} attributes={TextAttributes.BOLD}>
        Review requested
      </text>
      <text fg={theme.text.muted}>{props.request.summary}</text>
      <box flexDirection="row" gap={2}>
        <For each={ACTIONS}>
          {(action) => (
            <text onMouseUp={() => props.onPick(action.value)} selectable={false}>
              <span style={{ fg: theme.text.base }}>{action.title}</span>
              <span style={{ fg: theme.text.muted }}>{` ${action.key}`}</span>
            </text>
          )}
        </For>
      </box>
    </box>
  )
}

function setup(context: Plugin.Context) {
  const rpc = () => context.client.rpc(TuicrReview)
  const flagged = new Map<string, Request>()
  let showing: string | undefined

  function send(status: Record<string, unknown>) {
    if (!process.env.REX_SESSION || typeof context.renderer?.setProgramStatus !== "function") return
    try {
      context.renderer.setProgramStatus(status)
    } catch {
      // A rejected report must never break the TUI.
    }
  }

  function rootOf(sessionID?: string) {
    if (!sessionID || !context.data.session.get(sessionID)) return undefined
    return context.data.session.root(sessionID)
  }

  function viewedRoot() {
    const route = context.ui.router.current()
    return route.type === "session" ? rootOf(route.sessionID) : undefined
  }

  // Every TUI on the shared server receives every request: only the ones showing the session answer it.
  function owns(request: Request) {
    const rootID = rootOf(request.sessionID)
    if (!rootID) return false
    if (viewedRoot() === rootID) return true
    const tabs = context.ui.tabs
    return tabs?.enabled?.() === true && tabs.list().some((tab) => tab.sessionID === rootID)
  }

  function flag(request: Request) {
    if (flagged.has(request.requestID) || !owns(request)) return
    flagged.set(request.requestID, request)
    const title = context.data.session.get(rootOf(request.sessionID)!)?.title
    send({
      state: "blocked",
      app: "opencode",
      id: statusID(request.requestID),
      title: title && clip(title, 64),
      message: clip(`Review requested: ${request.summary}`, 512),
    })
  }

  function unflag(requestID: string) {
    if (!flagged.delete(requestID)) return
    send({ state: "clear", id: statusID(requestID) })
    if (showing === requestID) context.ui.dialog.clear()
  }

  function ask(request: Request) {
    return new Promise<Decision | undefined>((resolve) => {
      context.ui.dialog.show(
        () => <Prompt request={request} onPick={(decision) => (resolve(decision), context.ui.dialog.clear())} />,
        () => resolve(undefined),
      )
    })
  }

  async function prompt() {
    if (showing) return
    const rootID = viewedRoot()
    const request = [...flagged.values()].find((item) => rootOf(item.sessionID) === rootID)
    if (!request) return
    showing = request.requestID
    const decision = await ask(request)
    showing = undefined
    if (!decision) return
    const { accepted } = await rpc().answer({ requestID: request.requestID, decision, rexSession: process.env.REX_SESSION })
    if (accepted) return
    unflag(request.requestID)
    context.ui.toast.show({ message: "This review request is no longer pending", variant: "error" })
  }

  async function sync() {
    try {
      const { requests } = (await rpc().pending({})) as { requests: Request[] }
      for (const request of requests) flag(request)
      await prompt()
    } catch {
      // The server may be restarting; the next focus retries.
    }
  }

  const cleanups = [
    rpc().events.on("requested", (event) => {
      flag(event.data as Request)
      void prompt()
    }),
    rpc().events.on("settled", (event) => unflag((event.data as Request).requestID)),
  ]
  context.renderer.on?.("focus", sync)
  context.keymap.layer(() => ({
    commands: [
      {
        id: "tuicr-review.pending",
        title: "Answer pending tuicr review request",
        palette: true,
        slash: { name: "review-request" },
        run: sync,
      },
    ],
  }))
  void sync()

  return () => {
    for (const cleanup of cleanups) cleanup()
    context.renderer.off?.("focus", sync)
    for (const requestID of flagged.keys()) send({ state: "clear", id: statusID(requestID) })
  }
}

export default Plugin.define({ id: "tuicr-review", setup })
