---
name: dotfiles
description: Installing tools, adding app/tool configs, or changing system settings on the user's machines (stow + Nix flake in ~/.dotfiles, nix-darwin on macOS, NixOS on Linux)
---

# Dotfiles

All configs and system packages live in `~/.dotfiles`, managed declaratively. Full layout, recipes and guardrails: `~/.dotfiles/AGENTS.md` — read it before making changes.

## Rules
- Never install manually (`brew install`, `apt install`, `npm -g`, `curl | sh`, ...).
- System CLI package: add to a module in `~/.dotfiles/nixos/home/**/*.nix`.
- macOS GUI app: add a cask to `~/.dotfiles/nixos/hosts/work/homebrew.nix`.
- Tool config: lives in a stow package `~/.dotfiles/<pkg>/` mirroring `$HOME`, linked with `stow <pkg>`. Edit the repo file, never a copy in `$HOME`.
- Configs in `~/.dotfiles` are shared across machines. Device-specific config goes in `~/.config/local/<tool>` (not in the repo), via the tool's existing local hook.
- Project-scoped toolchain: use the project's mise config, not Nix.
- Apply with `rebuild <host>` (e.g. `rebuild work`), bump inputs with `update <host>`. These need sudo: tell the user the command, do not run it.
