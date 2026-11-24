# opencode-automations

A TUI plugin for [OpenCode automations](https://github.com/anomalyco/opencode/pull/64160): browse them, see their runs and what triggers them, pause, resume or delete them.

## Requirements

- OpenCode 2.3.1 or later, with `"experimental": { "automations": true }` in `opencode.json`.

## Install

Add the plugin folder to `plugins` in `cli.json`:

```json
{ "plugins": ["./tui-plugins/automations"] }
```

`<leader>a` opens the picker. It is OpenCode's default for "List agents", so free it with `"keybinds": { "agent.list": "none" }`, or rebind `automations.open`.

## Usage

- `/automations` or `<leader>a`: every automation on the server, grouped by folder.
  - `enter` details, `ctrl+t` pause/resume, `ctrl+d` twice to delete.
- Details window:
  - **Runs**: `↑↓` or `ctrl+p/n` move, `enter` expand the output, `o` open the session the run woke.
  - **Trigger**: action, trigger and target, then the prompt or the formatted code.
- Sidebar: the current session's automations, foldable; click one for its details.
- A desktop notification when an automation runs while the terminal is not focused.

## Limitations

- OpenCode publishes no automation events and keeps only the last run, so the plugin polls every 30 seconds and records run history itself. Runs that happen while no TUI is open collapse into the latest one.
- The picker uses `gutter` and `footerColor`, which the select dialog accepts but does not document.
- Reformatting code drops its comments.
