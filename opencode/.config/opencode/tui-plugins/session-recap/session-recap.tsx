/** @jsxImportSource @opentui/solid */
import { createMemo, createSignal, onCleanup, Show } from "solid-js"
import { Plugin, usePlugin } from "@opencode/plugin/tui"
import { SyntaxStyle, TextAttributes } from "@opentui/core"

// Every `rounds` prompts, a cheap model refreshes the sidebar recap and renames the session when its title no longer fits.

const RECENT_MESSAGES = 20
const MESSAGE_CHARS = 1500
const SPINNER = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]

type Options = { rounds?: number; providerID?: string; modelID?: string }
type Recap = { text: string; round: number; error?: string }
type Message = { type: string; text?: string; content?: { type: string; text?: string }[] }

function messageText(message: Message): string {
  if (message.type === "user") return message.text ?? ""
  return (message.content ?? [])
    .filter((part) => part.type === "text")
    .map((part) => part.text ?? "")
    .join(" ")
}

function parse(output: string): { title?: string; recap?: string } {
  const json = output.match(/\{[\s\S]*\}/)?.[0]
  if (!json) throw new Error("model did not return JSON")
  const result = JSON.parse(json)
  return { title: result.title?.trim() || undefined, recap: result.recap?.trim() || undefined }
}

function Updating() {
  const context = usePlugin()
  const [frame, setFrame] = createSignal(0)
  const timer = setInterval(() => setFrame((i) => (i + 1) % SPINNER.length), 80)
  onCleanup(() => clearInterval(timer))
  return <text fg={context.theme.text.muted}>{`${SPINNER[frame()]} Updating`}</text>
}

function View(props: { recap?: Recap; loading: boolean; open: boolean; onToggle: () => void; onRefresh: () => void }) {
  const context = usePlugin()
  const style = createMemo(() =>
    SyntaxStyle.fromStyles(
      {
        default: { fg: context.theme.text.muted },
        "markup.strong": { fg: context.theme.text.base, bold: true },
        "markup.italic": { italic: true },
        "markup.strikethrough": { dim: true },
        "markup.raw": { fg: context.theme.text.feedback.warning.base },
        "markup.list": { fg: context.theme.text.base },
        "markup.link.label": { fg: context.theme.text.base, underline: true },
        "markup.link.url": { dim: true, underline: true },
      },
      context.renderer.nativeScene,
    ),
  )
  return (
    <box>
      <box flexDirection="row" justifyContent="space-between">
        <box flexDirection="row" gap={1} onMouseUp={props.onToggle}>
          <text fg={context.theme.text.base} selectable={false}>
            {props.open ? "▼" : "▶"}
          </text>
          <text fg={context.theme.text.base} attributes={TextAttributes.BOLD} selectable={false}>
            Recap
          </text>
        </box>
        <Show
          when={props.loading}
          fallback={
            <box onMouseUp={props.onRefresh}>
              <text fg={context.theme.text.muted} selectable={false}>
                {"\u{f0450} Refresh"}
              </text>
            </box>
          }
        >
          <Updating />
        </Show>
      </box>
      <Show when={props.open}>
        <Show when={props.recap?.text}>
          <markdown content={props.recap!.text} syntaxStyle={style()} fg={context.theme.text.muted} />
        </Show>
        <Show when={props.recap?.error}>
          <text fg={context.theme.text.muted}>Recap failed: {props.recap!.error}</text>
        </Show>
      </Show>
    </box>
  )
}

function setup(context: Plugin.Context) {
  const options = (context.options ?? {}) as Options
  const rounds = options.rounds ?? 5
  const model = {
    providerID: options.providerID ?? "amazon-bedrock",
    id: options.modelID ?? "claude_code_claude_sonnet_5_5",
  }
  const [recaps, update] = context.storage.store<Record<string, Recap>>("recaps", { initial: {} })
  // In memory on purpose: a durable flag would stay stuck if the TUI closed mid-request.
  const [running, setRunning] = createSignal<ReadonlySet<string>>(new Set())
  const setLoading = (sessionID: string, loading: boolean) =>
    setRunning((current) => {
      const next = new Set(current)
      loading ? next.add(sessionID) : next.delete(sessionID)
      return next
    })

  const userRounds = (sessionID: string) =>
    ((context.data.session.message.list(sessionID) ?? []) as Message[]).filter((m) => m.type === "user").length

  async function refresh(sessionID: string) {
    if (running().has(sessionID)) return
    setLoading(sessionID, true)
    try {
      await context.data.session.message.sync(sessionID)
      const messages = (context.data.session.message.list(sessionID) ?? []) as Message[]
      const round = userRounds(sessionID)
      const transcript = messages
        .filter((m) => m.type === "user" || m.type === "assistant")
        .slice(-RECENT_MESSAGES)
        .map((m) => `${m.type}: ${messageText(m).trim().slice(0, MESSAGE_CHARS)}`)
        .join("\n\n")
      if (!transcript) return

      const session = context.data.session.get(sessionID)
      const previous = recaps[sessionID]?.text
      try {
        const result = await context.client.generate.text(
          {
            model,
            prompt: `You maintain the title and recap of a coding session. Reply with JSON only:
{"title": string | null, "recap": string}

title: a specific title of at most 12 words describing what the session is about now.
Use null when the current title still fits; only rename when the focus has clearly changed or the title is vague.

recap: Markdown, about 40 words, no tables or headings. Use **bold** for key names, *italic* for state, \`code\` for files/commands, and [label](url) links only for URLs that appear in the transcript:
🎯 **Working on:** one sentence describing the overarching (medium term, not immediate) situation
✅ **Done:** short list of medium term tasks as bullet points (omit if none)
➡️ **Next:** short and mid term objectives as bullet points (omit if none)

CURRENT TITLE: ${session?.title ?? "(none)"}
${previous ? `PREVIOUS RECAP:\n${previous}\n` : ""}
RECENT TRANSCRIPT:
${transcript}`,
          },
          { signal: AbortSignal.timeout(60_000) },
        )
        const { title, recap } = parse(result?.text ?? "")
        if (title && title !== session?.title) await context.client.session.update({ sessionID, title })
        await update((draft) => {
          draft[sessionID] = { text: recap ?? previous ?? "", round }
        })
      } catch (error) {
        const message = error instanceof Error ? error.message : String(error)
        // Keep the last good recap and record the round so a failure is not retried on every prompt.
        await update((draft) => {
          draft[sessionID] = { text: previous ?? "", round, error: message }
        })
      }
    } finally {
      setLoading(sessionID, false)
    }
  }

  const stop = context.data.on("session.execution.succeeded", (event) => {
    const sessionID = event.data.sessionID
    if (!sessionID || context.data.session.root(sessionID) !== sessionID) return
    const recap = recaps[sessionID]
    const round = userRounds(sessionID)
    if (recap ? round - recap.round >= rounds : round > 0) void refresh(sessionID)
  })

  const [view, updateView] = context.storage.store("view", { initial: { open: true } })
  const currentSession = () => {
    const route = context.ui.router.current()
    return route.type === "session" ? route.sessionID : undefined
  }

  context.keymap.layer(() => ({
    mode: "global",
    commands: [
      {
        id: "session-recap.refresh",
        title: "Refresh recap",
        group: "Session",
        palette: true,
        slash: { name: "recap" },
        enabled: () => currentSession() !== undefined,
        run: () => {
          const sessionID = currentSession()
          if (sessionID) void refresh(sessionID)
        },
      },
    ],
  }))

  context.ui.slot({
    append: "sidebar.content",
    render: (input) => (
      <View
        recap={recaps[input.sessionID]}
        loading={running().has(input.sessionID)}
        open={view.open}
        onToggle={() =>
          void updateView((draft) => {
            draft.open = !draft.open
          })
        }
        onRefresh={() => refresh(input.sessionID)}
      />
    ),
  })

  return () => stop()
}

export default Plugin.define({ id: "local.session-recap", setup })
