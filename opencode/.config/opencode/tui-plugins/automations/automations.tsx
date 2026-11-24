/** @jsxImportSource @opentui/solid */
import { createSignal, For, onCleanup, Show } from "solid-js"
import { Plugin, usePlugin } from "@opencode/plugin/tui"
import { SyntaxStyle, TextAttributes, type ScrollBoxRenderable } from "@opentui/core"

// Automations publish no events, so the list is polled; a rising runCount is what triggers a notification.

const POLL_MS = 30_000

type Theme = Plugin.Context["theme"]

type Automation = {
  id: string
  name: string
  sessionID?: string
  directory: string
  trigger:
    | { type: "at"; at: string }
    | { type: "every"; every: string }
    | { type: "cron"; cron: string }
    | { type: "event"; server: string; event: string }
  action:
    | { type: "prompt"; prompt: string; to: { session?: string; subagent?: string } }
    | { type: "code"; code: string }
  tz?: string
  expires?: number
  status: "active" | "paused" | "done"
  nextDueAt?: number
  runCount: number
  lastRunAt?: number
  lastOutcome?: string
  lastOutput?: string
  time: { updated: number }
}

const ICON = { active: "●", paused: "◌", done: "✓" }

function describeTrigger(a: Automation) {
  switch (a.trigger.type) {
    case "at":
      return `at ${a.trigger.at}`
    case "every":
      return `every ${a.trigger.every}`
    case "cron":
      return `cron ${a.trigger.cron}`
    case "event":
      return `on ${a.trigger.server}/${a.trigger.event}`
  }
}

function relative(ms: number) {
  const minutes = Math.round((ms - Date.now()) / 60_000)
  const abs = Math.abs(minutes)
  if (abs < 1) return "now"
  const text = abs < 60 ? `${abs}m` : abs < 1440 ? `${Math.round(abs / 60)}h` : `${Math.round(abs / 1440)}d`
  return minutes > 0 ? `in ${text}` : `${text} ago`
}

const date = (ms?: number) => (ms ? new Date(ms).toLocaleString() : undefined)

function schedule(a: Automation) {
  return a.status === "active" && a.nextDueAt ? `next ${relative(a.nextDueAt)}` : a.status
}

// A prompt run reports the session it woke, or the subagent child it started, in its output.
function runSession(a: Automation) {
  return a.lastOutput?.match(/\bses_\w+/)?.[0] ?? a.sessionID
}

type Kind = "info" | "success" | "warning" | "error"

function outcomeKind(outcome: string): Kind {
  if (outcome === "failed" || outcome === "expired") return "error"
  if (outcome === "late" || outcome === "skipped" || outcome === "disabled") return "warning"
  return "success"
}

function statusColor(theme: Theme, a: Automation) {
  if (a.lastOutcome === "failed" || a.lastOutcome === "expired") return theme.text.feedback.error.base
  if (a.status === "active") return theme.text.feedback.success.base
  if (a.status === "paused") return theme.text.feedback.warning.base
  return theme.text.muted
}

// Code Mode programs may `return` at top level, so they are reprinted inside a function. Bun's printer drops comments.
function format(code: string) {
  try {
    return new Bun.Transpiler({ loader: "js" })
      .transformSync(`async function __() {\n${code}\n}`)
      .trim()
      .split("\n")
      .slice(1, -1)
      .map((line) => line.replace(/^ {2}/, ""))
      .join("\n")
  } catch {
    return code
  }
}

function codeStyle(theme: Theme, owner: Plugin.Context["renderer"]["nativeScene"]) {
  const s = theme.syntax
  return SyntaxStyle.fromStyles(
    {
      default: { fg: theme.text.base },
      comment: { fg: s.comment, italic: true },
      string: { fg: s.string },
      number: { fg: s.number },
      boolean: { fg: s.number },
      constant: { fg: s.number },
      keyword: { fg: s.keyword, italic: true },
      operator: { fg: s.operator },
      punctuation: { fg: s.punctuation },
      "punctuation.delimiter": { fg: s.operator },
      variable: { fg: s.variable },
      property: { fg: s.variable },
      function: { fg: s.function },
      "function.call": { fg: s.function },
      "function.method.call": { fg: s.function },
      type: { fg: s.type },
      "variable.builtin": { fg: theme.text.feedback.error.base },
    },
    owner,
  )
}

function Pill(props: { label: string; kind?: Kind }) {
  const context = usePlugin()
  const theme = context.theme
  return (
    <text
      bg={props.kind ? theme.background.feedback[props.kind].base : theme.background.raised.high}
      fg={props.kind ? theme.text.feedback[props.kind].base : theme.text.base}
      selectable={false}
    >
      {` ${props.label} `}
    </text>
  )
}

function Field(props: { label: string; value: string }) {
  const context = usePlugin()
  return (
    <box flexDirection="row" gap={1}>
      <text fg={context.theme.text.muted} width={9} flexShrink={0}>
        {props.label}
      </text>
      <text fg={context.theme.text.base}>{props.value}</text>
    </box>
  )
}

function LastRunView(props: { automation: Automation; height: number; ref: (scroll: ScrollBoxRenderable) => void }) {
  const context = usePlugin()
  const a = props.automation
  const fields = [
    ["Ran", a.lastRunAt ? `${date(a.lastRunAt)} (${relative(a.lastRunAt)})` : undefined],
    ["Runs", String(a.runCount)],
    ["Next", a.status === "active" ? date(a.nextDueAt) : undefined],
    ["Session", runSession(a)],
  ].filter((field): field is [string, string] => Boolean(field[1]))
  return (
    <box height={props.height} gap={1}>
      <Show when={a.lastOutcome}>
        <box flexDirection="row" gap={1} flexShrink={0}>
          <Pill label={a.lastOutcome!} kind={outcomeKind(a.lastOutcome!)} />
          <Pill label={a.status} />
        </box>
        <box flexShrink={0}>
          <For each={fields}>{([label, value]) => <Field label={label} value={value} />}</For>
        </box>
        <scrollbox ref={props.ref} flexGrow={1}>
          <text fg={context.theme.text.base}>{a.lastOutput || "No output"}</text>
        </scrollbox>
      </Show>
    </box>
  )
}

function TriggerView(props: { automation: Automation; height: number; ref: (scroll: ScrollBoxRenderable) => void }) {
  const context = usePlugin()
  const a = props.automation
  const style = codeStyle(context.theme, context.renderer.nativeScene)
  onCleanup(() => void context.renderer.idle().then(() => style.destroy()))
  const body = a.action.type === "code" ? format(a.action.code) : a.action.prompt
  const target = a.action.type === "prompt" && a.action.to?.subagent
  const fields = [
    ["Trigger", describeTrigger(a)],
    ["Timezone", a.tz],
    ["Next", a.status === "active" ? date(a.nextDueAt) : undefined],
    ["Expires", date(a.expires)],
    ["Folder", context.ui.format.path(a.directory)],
  ].filter((field): field is [string, string] => Boolean(field[1]))
  return (
    <box height={props.height} gap={1}>
      <box flexDirection="row" gap={1} flexShrink={0}>
        <Pill label={a.action.type} kind={a.action.type === "code" ? "info" : "success"} />
        <Pill label={a.trigger.type} />
        <Show when={a.action.type === "prompt"}>
          <Pill label={target ? `subagent ${target}` : "session"} kind={target ? "warning" : undefined} />
        </Show>
      </box>
      <box flexShrink={0}>
        <For each={fields}>{([label, value]) => <Field label={label} value={value} />}</For>
      </box>
      <scrollbox ref={props.ref} flexGrow={1}>
        <Show when={a.action.type === "code"} fallback={<text fg={context.theme.text.base}>{body}</text>}>
          <code content={body} filetype="javascript" syntaxStyle={style} wrapMode="word" />
        </Show>
      </scrollbox>
    </box>
  )
}

const TABS = ["Last run", "Trigger"] as const

function Details(props: { automation: Automation; onOpen: () => void }) {
  const context = usePlugin()
  const theme = context.theme
  const a = props.automation
  const height = Math.max(8, Math.min(24, context.renderer.height - 14))
  const [tab, setTab] = createSignal<(typeof TABS)[number]>("Last run")
  let scroll: ScrollBoxRenderable | undefined

  context.keymap.layer(() => ({
    mode: "modal",
    commands: [
      { bind: "tab", run: () => setTab((current) => (current === TABS[0] ? TABS[1] : TABS[0])) },
      { bind: "up,ctrl+p", run: () => scroll?.scrollBy(-1) },
      { bind: "down,ctrl+n", run: () => scroll?.scrollBy(1) },
      { bind: "o", run: props.onOpen },
    ],
  }))

  return (
    <box paddingLeft={2} paddingRight={2} paddingBottom={1} gap={1}>
      <box flexDirection="row" justifyContent="space-between">
        <box flexDirection="row" gap={1}>
          <text fg={statusColor(theme, a)}>{ICON[a.status]}</text>
          <text fg={theme.text.base} attributes={TextAttributes.BOLD}>
            {a.name}
          </text>
        </box>
        <text fg={theme.text.muted}>{schedule(a)}</text>
      </box>
      <box flexDirection="row" gap={2}>
        <For each={TABS}>
          {(name) => (
            <box onMouseUp={() => setTab(name)}>
              <text
                fg={tab() === name ? theme.text.base : theme.text.muted}
                attributes={tab() === name ? TextAttributes.BOLD | TextAttributes.UNDERLINE : 0}
                selectable={false}
              >
                {name}
              </text>
            </box>
          )}
        </For>
      </box>
      <Show when={tab() === "Last run"}>
        <LastRunView automation={a} height={height} ref={(r) => (scroll = r)} />
      </Show>
      <Show when={tab() === "Trigger"}>
        <TriggerView automation={a} height={height} ref={(r) => (scroll = r)} />
      </Show>
      <text fg={theme.text.muted}>tab switch · ↑↓ scroll · o open session · esc back</text>
    </box>
  )
}

function Sidebar(props: {
  automations: Automation[]
  open: boolean
  onToggle: () => void
  onSelect: (a: Automation) => void
}) {
  const context = usePlugin()
  const theme = context.theme
  return (
    <Show when={props.automations.length > 0}>
      <box>
        <box flexDirection="row" gap={1} onMouseUp={props.onToggle}>
          <text fg={theme.text.base} selectable={false}>
            {props.open ? "▼" : "▶"}
          </text>
          <text fg={theme.text.base} attributes={TextAttributes.BOLD} selectable={false}>
            Automations
          </text>
          <Show when={!props.open}>
            <text fg={theme.text.muted} selectable={false}>{`(${props.automations.length})`}</text>
          </Show>
        </box>
        <Show when={props.open}>
          <For each={props.automations}>
            {(a) => (
              <box flexDirection="row" justifyContent="space-between" gap={1} onMouseUp={() => props.onSelect(a)}>
                <box flexDirection="row" gap={1} flexShrink={1}>
                  <text fg={statusColor(theme, a)} flexShrink={0}>
                    {ICON[a.status]}
                  </text>
                  <text fg={a.status === "active" ? theme.text.base : theme.text.muted} wrapMode="none" overflow="hidden">
                    {a.name}
                  </text>
                </box>
                <text fg={theme.text.muted} flexShrink={0} wrapMode="none">
                  {schedule(a)}
                </text>
              </box>
            )}
          </For>
        </Show>
      </box>
    </Show>
  )
}

function setup(context: Plugin.Context) {
  const api = context.client.experimental?.automation
  if (!api) return
  const [automations, setAutomations] = createSignal<Automation[]>([])
  const [view, updateView] = context.storage.store("view", { initial: { open: true } })
  let runCounts: Map<string, number> | undefined

  function notify(list: Automation[]) {
    for (const a of list) {
      const seen = runCounts?.get(a.id)
      if (seen === undefined || a.runCount <= seen) continue
      void context.attention.notify({
        title: `Automation: ${a.name}`,
        message: a.lastOutput?.slice(0, 200) || a.lastOutcome || "ran",
        notification: { when: "blurred" },
      })
    }
    runCounts = new Map(list.map((a) => [a.id, a.runCount]))
  }

  async function poll() {
    const list = (await api.list().catch(() => undefined)) as Automation[] | undefined
    if (!list) return automations()
    notify(list)
    setAutomations(list)
    return list
  }

  void poll()
  const timer = setInterval(() => void poll(), POLL_MS)

  function showDetails(a: Automation, returnToPicker = true) {
    let navigated = false
    context.ui.dialog.show(
      () => (
        <Details
          automation={a}
          onOpen={() => {
            const sessionID = runSession(a)
            if (!sessionID) return
            navigated = true
            context.ui.dialog.clear()
            context.ui.router.navigate({ type: "session", sessionID })
          }}
        />
      ),
      () => {
        if (returnToPicker && !navigated) setTimeout(() => void showPicker(a.id), 0)
      },
    )
    context.ui.dialog.set({ size: "xlarge" })
  }

  const currentSession = () => {
    const route = context.ui.router.current()
    return route.type === "session" ? route.sessionID : undefined
  }
  // Like OpenCode's session list, the picker opens on the current session's automations and ctrl+a shows all of them.
  let showAll = false

  // `deleting` marks the row armed by a first ctrl+d, like OpenCode's session list. Options are static once shown,
  // so arming re-shows the picker from the last poll.
  async function showPicker(current?: string, deleting?: string) {
    const everything = deleting ? automations() : await poll()
    if (everything.length === 0) {
      context.ui.toast.show({ message: "No automations. Create one with /automation", variant: "info" })
      return
    }
    const sessionID = currentSession()
    const scoped = !showAll && sessionID !== undefined
    const list = scoped ? everything.filter((a) => a.sessionID === sessionID) : everything
    const byID = new Map(list.map((a) => [a.id, a]))
    const refresh = (id: string, action: Promise<unknown>) =>
      action
        .catch((error) => context.ui.toast.show({ message: String(error), variant: "error" }))
        .finally(() => {
          context.ui.dialog.clear()
          void showPicker(id)
        })
    // Enter both resolves the picker and triggers the "Details" action that advertises it in the footer; open once.
    let opened = false
    const details = (id: string) => {
      const a = byID.get(id)
      if (opened || !a) return
      opened = true
      context.ui.dialog.clear()
      showDetails(a)
    }
    const picked = context.ui.dialog.select({
      title: scoped ? "Automations in this session" : "Automations",
      current,
      // gutter, footerColor, bg and fg are undocumented: the host spreads options into its internal DialogSelect.
      options: list.map((a) => {
        const base = { value: a.id, category: context.ui.format.path(a.directory) }
        if (a.id === deleting)
          return {
            ...base,
            title: "Press ctrl+d again to confirm",
            bg: context.theme.background.action.destructive.focused,
            fg: context.theme.text.action.destructive.focused,
          }
        return {
          ...base,
          title: a.name,
          description: `${describeTrigger(a)} · ${a.action.type}`,
          footer: schedule(a),
          footerColor: statusColor(context.theme, a),
          gutter: () => <text fg={statusColor(context.theme, a)}>{ICON[a.status]}</text>,
        }
      }),
      actions: [
        { bind: "return", title: "Details", onTrigger: details },
        ...(sessionID === undefined
          ? []
          : [
              {
                bind: "ctrl+a",
                title: scoped ? "Show all" : "Show this session",
                selection: "none" as const,
                onTrigger: () => {
                  showAll = !showAll
                  void showPicker(current)
                },
              },
            ]),
        {
          bind: "ctrl+t",
          title: "Pause/resume",
          onTrigger: (id) => {
            const a = byID.get(id)
            if (!a || a.status === "done") return
            void refresh(id, a.status === "paused" ? api.resume({ automationID: id }) : api.pause({ automationID: id }))
          },
        },
        {
          bind: "ctrl+d",
          title: "Delete",
          onTrigger: (id) => {
            if (id === deleting) void refresh(id, api.delete({ automationID: id }))
            else void showPicker(id, id)
          },
        },
      ],
    })
    context.ui.dialog.set({ size: "large" })
    const id = await picked
    if (id) details(id)
  }

  context.keymap.layer(() => ({
    mode: "global",
    commands: [
      {
        id: "automations.open",
        title: "Automations",
        group: "Session",
        bind: "<leader>a",
        palette: true,
        slash: { name: "automations" },
        run: () => {
          showAll = false
          void showPicker()
        },
      },
    ],
  }))

  context.ui.slot({
    append: "sidebar.content",
    render: (input) => (
      <Sidebar
        automations={automations().filter((a) => a.sessionID === input.sessionID)}
        open={view.open}
        onToggle={() =>
          void updateView((draft) => {
            draft.open = !draft.open
          })
        }
        onSelect={(a) => showDetails(a, false)}
      />
    ),
  })

  return () => clearInterval(timer)
}

export default Plugin.define({ id: "local.automations", setup })
