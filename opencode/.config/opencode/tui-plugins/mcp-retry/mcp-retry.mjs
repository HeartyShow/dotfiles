const RETRYABLE = new Set(["failed", "pending"])

async function retryAll(context) {
  const location = context.location ?? context.data.location.default()
  await context.data.location.mcp.server.sync(location)
  const servers = context.data.location.mcp.server.list(location) ?? []
  const retry = servers.filter((server) => RETRYABLE.has(server.status.status))
  const needsAuth = servers.filter((server) => server.status.status === "needs_auth").length

  if (retry.length === 0 && needsAuth === 0) {
    context.ui.toast.show({ message: "All MCP servers are connected", variant: "success" })
    return
  }

  context.ui.toast.show({ message: `Reconnecting ${retry.length} MCP server(s)…`, variant: "info" })
  const results = await Promise.allSettled(
    retry.map((server) => context.client.experimental.mcp.connect({ server: server.name, location })),
  )
  context.data.location.mcp.server.invalidate(location)

  const failed = retry.filter((_, index) => results[index].status === "rejected").map((server) => server.name)
  const parts = [`Reconnected ${retry.length - failed.length}/${retry.length}`]
  if (failed.length) parts.push(`failed: ${failed.join(", ")}`)
  if (needsAuth) parts.push(`${needsAuth} need sign-in in /mcps`)
  context.ui.toast.show({ message: parts.join(" · "), variant: failed.length || needsAuth ? "warning" : "success" })
}

export default {
  id: "local.mcp-retry",
  setup(context) {
    context.keymap.layer(() => ({
      mode: "global",
      commands: [
        {
          id: "mcp.retry-all",
          title: "Reconnect all MCP servers",
          group: "MCP",
          palette: true,
          slash: { name: "mcp-retry" },
          run: () =>
            void retryAll(context).catch((error) =>
              context.ui.toast.show({ message: String(error), variant: "error" }),
            ),
        },
      ],
    }))
  },
}
