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
  - `enter` details, `ctrl+a` this session / all, `ctrl+t` pause/resume, `ctrl+d` twice to delete.
- Details window:
  - **Last run**: outcome, time, run count and output; `o` opens the session it woke.
  - **Trigger**: action, trigger and target, then the prompt or the formatted code.
- Sidebar: the current session's automations, foldable; click one for its details.
- A desktop notification when an automation runs while the terminal is not focused.

## Limitations

- OpenCode publishes no automation events and keeps only the last run, so the plugin polls every 30 seconds and shows that run only.
- The picker uses `gutter` and `footerColor`, which the select dialog accepts but does not document.
- Reformatting code drops its comments.
