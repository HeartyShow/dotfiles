/** @jsxImportSource @opentui/solid */
import { createSignal, For, onCleanup, Show } from "solid-js"
import { Plugin, usePlugin } from "@opencode/plugin/tui"
import { RGBA, SyntaxStyle, TextAttributes, type ScrollBoxRenderable } from "@opentui/core"

// Automations publish no events and keep no run history, so the list is polled and each change of a run's
// outcome is recorded locally. Runs that happen while no TUI is open collapse into the latest one.

const POLL_MS = 30_000
const MAX_RUNS = 50

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

type Run = { key: string; at: number; outcome: string; output?: string }

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

function runKey(a: Automation) {
  return `${a.runCount}|${a.lastOutcome}|${a.lastOutput}`
}

// A prompt run reports the session it woke, or the subagent child it started, in its output.
function runSession(a: Automation, run: Run) {
  return run.output?.match(/\bses_\w+/)?.[0] ?? a.sessionID
}

function outcomeColor(theme: Theme, outcome?: string) {
  if (outcome === "failed" || outcome === "expired") return theme.text.feedback.error.base
  if (outcome === "late" || outcome === "skipped" || outcome === "disabled") return theme.text.feedback.warning.base
  return theme.text.feedback.success.base
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

function Pill(props: { label: string; kind?: "info" | "success" | "warning" }) {
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

function RunList(props: {
  runs: Run[]
  height: number
  selected: number
  expanded?: number
  onSelect: (index: number) => void
  onToggle: (index: number) => void
  ref: (scroll: ScrollBoxRenderable) => void
}) {
  const context = usePlugin()
  const theme = context.theme
  return (
    <scrollbox ref={props.ref} height={props.height}>
      <For each={props.runs}>
        {(run, index) => {
          const active = () => props.selected === index()
          return (
            <box id={`run-${index()}`} onMouseOver={() => props.onSelect(index())} onMouseUp={() => props.onToggle(index())}>
              <box
                flexDirection="row"
                gap={1}
                paddingLeft={1}
                paddingRight={1}
                backgroundColor={active() ? theme.background.action.primary.focused : RGBA.fromInts(0, 0, 0, 0)}
              >
                <text fg={active() ? theme.text.action.primary.focused : outcomeColor(theme, run.outcome)}>●</text>
                <text flexGrow={1} fg={active() ? theme.text.action.primary.focused : theme.text.base} wrapMode="none">
                  {date(run.at)}
                  <span style={{ fg: active() ? theme.text.action.secondary.focused : outcomeColor(theme, run.outcome) }}>
                    {` ${run.outcome}`}
                  </span>
                </text>
                <text fg={active() ? theme.text.action.secondary.focused : theme.text.muted}>{relative(run.at)}</text>
              </box>
              <Show when={props.expanded === index()}>
                <box paddingLeft={3} paddingRight={1} paddingTop={1} paddingBottom={1}>
                  <text fg={theme.text.muted}>{run.output || "No output"}</text>
                </box>
              </Show>
            </box>
          )
        }}
      </For>
    </scrollbox>
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

const TABS = ["Runs", "Trigger"] as const

function Details(props: { automation: Automation; runs: Run[]; onOpen: (run: Run) => void }) {
  const context = usePlugin()
  const theme = context.theme
  const a = props.automation
  const height = Math.max(8, Math.min(24, context.renderer.height - 14))
  const [tab, setTab] = createSignal<(typeof TABS)[number]>("Runs")
  const [selected, setSelected] = createSignal(0)
  const [expanded, setExpanded] = createSignal<number>()
  let runsScroll: ScrollBoxRenderable | undefined
  let bodyScroll: ScrollBoxRenderable | undefined

  const move = (delta: number) => {
    if (tab() === "Trigger") return bodyScroll?.scrollBy(delta)
    const next = Math.max(0, Math.min(props.runs.length - 1, selected() + delta))
    setSelected(next)
    runsScroll?.scrollChildIntoView(`run-${next}`)
  }
  const toggle = (index: number) => {
    setSelected(index)
    setExpanded((current) => (current === index ? undefined : index))
  }
  const openSelected = () => {
    const run = props.runs[selected()]
    if (tab() === "Runs" && run) props.onOpen(run)
  }

  context.keymap.layer(() => ({
    mode: "modal",
    commands: [
      { bind: "tab", run: () => setTab((current) => (current === "Runs" ? "Trigger" : "Runs")) },
      { bind: "up,ctrl+p", run: () => move(-1) },
      { bind: "down,ctrl+n", run: () => move(1) },
      { bind: "return", run: () => (tab() === "Runs" && props.runs.length ? toggle(selected()) : undefined) },
      { bind: "o", run: openSelected },
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
                {name === "Runs" ? `Runs (${props.runs.length})` : name}
              </text>
            </box>
          )}
        </For>
      </box>
      <Show when={tab() === "Runs"}>
        <RunList
          runs={props.runs}
          height={height}
          selected={selected()}
          expanded={expanded()}
          onSelect={setSelected}
          onToggle={toggle}
          ref={(scroll) => (runsScroll = scroll)}
        />
      </Show>
      <Show when={tab() === "Trigger"}>
        <TriggerView automation={a} height={height} ref={(scroll) => (bodyScroll = scroll)} />
      </Show>
      <text fg={theme.text.muted}>
        {tab() === "Runs"
          ? "tab switch · ↑↓ move · enter expand · o open session · esc back"
          : "tab switch · ↑↓ scroll · esc back"}
      </text>
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
  const [history, updateHistory] = context.storage.store<Record<string, Run[]>>("runs", { initial: {} })
  const [view, updateView] = context.storage.store("view", { initial: { open: true } })
  let runCounts: Map<string, number> | undefined

  function record(list: Automation[]) {
    const ids = new Set(list.map((a) => a.id))
    const changed = list.filter((a) => a.lastOutcome && history[a.id]?.at(-1)?.key !== runKey(a))
    const deleted = Object.keys(history).filter((id) => !ids.has(id))
    if (changed.length === 0 && deleted.length === 0) return
    void updateHistory((draft) => {
      for (const id of deleted) delete draft[id]
      for (const a of changed) {
        const run = { key: runKey(a), at: a.lastRunAt ?? a.time.updated, outcome: a.lastOutcome!, output: a.lastOutput }
        draft[a.id] = [...(draft[a.id] ?? []), run].slice(-MAX_RUNS)
      }
    })
  }

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
    record(list)
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
          runs={[...(history[a.id] ?? [])].reverse()}
          onOpen={(run) => {
            const sessionID = runSession(a, run)
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

  // `deleting` marks the row armed by a first ctrl+d, like OpenCode's session list. Options are static once shown,
  // so arming re-shows the picker from the last poll.
  async function showPicker(current?: string, deleting?: string) {
    const list = deleting ? automations() : await poll()
    if (list.length === 0) {
      context.ui.toast.show({ message: "No automations. Create one with /automation", variant: "info" })
      return
    }
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
      title: "Automations",
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
        run: () => void showPicker(),
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
