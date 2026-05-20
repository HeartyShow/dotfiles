# Global Rules

## Code quality
- Treat every line of code as a liability. Less code is better. Prefer deleting code over adding it.
- Favour readability and maintainability over cleverness.
- Do not introduce abstractions until the duplication is proven (Rule of Three).
- Every dependency added is a maintenance burden -- justify it.
- No dead code, no commented-out code.

## Security
- When reviewing or writing code, delegate security concerns to @security.
- Never hardcode secrets, tokens, or credentials.
- Validate and sanitize all external input.

## Environment
- I use git worktrees (bare clone + worktrunk), use the dedicated skill.
- I use Nix (nix-darwin on macOS, NixOS on Linux). For system-level changes, modify the flake, don't install manually, check the dedicated skill

## Coding style
- Code should be self-documenting, comments should only explain hard-to-read and specific behaviors.
- Use conventional commits (feat:, fix:, chore:, docs:, refactor:).
- When developing a feature for a codebase with a testing framework, test it and follow the existing patterns.

## Diagrams
- Always use mermaid code blocks (```mermaid) for diagrams and flowcharts.
  Never generate raw ASCII art diagrams — a plugin renders mermaid to ASCII automatically.
- Prefer top-down (TD) layout over left-right (LR) to avoid horizontal overflow,
  but use LR when the content genuinely flows better horizontally.
- Keep diagrams concise — they render as ASCII art in a terminal at large font size.
  Favour fewer nodes with clear labels over exhaustive detail.
- Supported diagram types: flowcharts (graph TD/LR/BT/RL), state diagrams,
  sequence diagrams, class diagrams, ER diagrams, XY charts.
  Do NOT use unsupported types (pie, gantt, mindmap, timeline, etc.).
- Do NOT use <br/> `\n` or HTML tags in node labels — they are not rendered.
  Use short single-line labels instead.

## Behavior
- Always check for existing tests before modifying logic.
- When unsure about a framework API, use context7 to check current
  docs before guessing.
- If unsure how to implement something, use gh_grep to search
  real code examples from GitHub.
