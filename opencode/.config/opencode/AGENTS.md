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

## Company context
- When a task needs company context (tickets, specs, design docs, Slack discussions, PR history, hiring data), delegate to @research instead of guessing.
- Typical triggers: a Linear key (e.g. ABC-123), "the spec/RFC for…", "what was decided about…", "who owns…", links to Notion/Slack/Drive/Linear.
- Do not use @research for code answerable from the repo, library docs (use context7), or public code examples (use gh_grep).

## Environment
- I use git worktrees (bare clone + worktrunk), use the dedicated skill.
- Configs and system packages live in ~/.dotfiles (stow + Nix flake, nix-darwin on macOS, NixOS on Linux); never install manually, use the `dotfiles` skill.

## Coding style
- Code should be self-documenting, comments should only explain hard-to-read and specific behaviors.
- Use conventional commits (feat:, fix:, chore:, docs:, refactor:).
- When developing a feature for a codebase with a testing framework, test it and follow the existing patterns.

## Diagrams
- Always use mermaid code blocks (```mermaid) for diagrams and flowcharts.
  Never generate raw ASCII art diagrams — OpenCode renders mermaid natively.
- Prefer top-down (TD) layout over left-right (LR) to avoid horizontal overflow,
  but use LR when the content genuinely flows better horizontally.
- Keep diagrams concise: favour fewer nodes with clear labels over exhaustive detail.
- Do NOT use pie charts — they are not rendered; use a table instead.

## Behavior
- Always check for existing tests before modifying logic.
- When unsure about a framework API, use context7 to check current
  docs before guessing.
- If unsure how to implement something, use gh_grep to search
  real code examples from GitHub.
- When referencing PRs, issues, docs, commits or repo files, embed markdown links.
