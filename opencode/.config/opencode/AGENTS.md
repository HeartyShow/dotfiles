# Global Rules

## Code quality
- Treat every line of code as a liability. Less code is better.
  Prefer deleting code over adding it.
- Favour readability and maintainability over cleverness.
- Do not introduce abstractions until the duplication is proven
  (Rule of Three).
- Every dependency added is a maintenance burden -- justify it.
- Leave code in a better state than you found it.
- No dead code, no commented-out code, no TODO without a ticket reference.

## Security
- When reviewing or writing code, delegate security concerns to @security.
- Never hardcode secrets, tokens, or credentials.
- Validate and sanitize all external input.

## Environment
- I use git worktrees (bare clone + worktrunk).
  The `.git` dir is one level above the worktree checkout.
- I use Nix (nix-darwin on macOS, NixOS on Linux).
  For system-level changes, modify the flake, don't install manually.

## Coding style
- Use conventional commits (feat:, fix:, chore:, docs:, refactor:).
- When writing TypeScript, prefer explicit return types on exported functions.
- Prefer functional patterns where they improve readability.

## Behavior
- Always check for existing tests before modifying logic.
- When unsure about a framework API, use context7 to check current
  docs before guessing.
