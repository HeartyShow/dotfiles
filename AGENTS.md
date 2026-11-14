# Dotfiles

Personal config for macOS (nix-darwin) and Linux (NixOS, WSL). Everything is declarative: the repo is the source of truth, nothing is installed or configured by hand.

## Layout
- `<pkg>/` (every top-level dir except `nixos/`): a GNU Stow package mirroring `$HOME`, e.g. `nvim/.config/nvim/` -> `~/.config/nvim`, `zsh/.zshrc` -> `~/.zshrc`.
- `stow/.stow-global-ignore`: stow ignore patterns.
- `nixos/`: Nix flake (not a stow package).
  - `flake.nix`: hosts `work` (nix-darwin, aarch64-darwin), `wsl` and `media-server` (NixOS, x86_64-linux).
  - `home/{code,programs,shell}/*.nix`: shared package modules, one topic per file, using `environment.systemPackages` (home-manager is not used).
  - `darwin/`: macOS system defaults (dock, keyboard, ...).
  - `hosts/<host>/`: host-specific config; `hosts/work/homebrew.nix` holds GUI apps as casks.
- NixOS hosts import `home/*` via `default.nix`; the `work` darwin host lists each module explicitly in `flake.nix`.

## Shared vs machine-local
- Everything in this repo is shared across all machines. Device-specific config (work tooling, per-machine PATH, credentials, signing keys, per-device agent/MCP config) does NOT go here.
- It goes in `~/.config/local/` (not in the repo, not stowed), loaded by optional hooks in the shared configs: zsh `zshrc`, tmux `tmux.conf`, git `git.conf`/`allowed_signers`, lazygit `lazygit.yml`, opencode `opencode/opencode.json`; machine-only scripts in `bin/`.
- New tool needing local overrides: add an optional include in the shared config (silently skipped if the file is missing), following the existing hooks.

## Recipes
- New tool config: create `<pkg>/.config/<pkg>/...`, then `stow <pkg>` from `~/.dotfiles`. Add generated/state files to `.gitignore`.
- New CLI package: add it to the matching `nixos/home/**/*.nix` module (or create one and import it for the right hosts).
- New macOS GUI app: add a cask to `nixos/hosts/work/homebrew.nix`.
- macOS setting: add/edit a module in `nixos/darwin/`.
- Project-specific toolchain: use the project's mise config, not Nix.
- Apply: `rebuild <host>` (e.g. `rebuild work`); bump inputs: `update <host>`. Both defined in `zsh/.zshrc`.

## Guardrails
- Never `brew install`, `apt install`, `npm -g`, `curl | sh`, or edit files in `$HOME` that are symlinks into this repo from outside it.
- Never commit machine-specific values (hostnames, work paths, tokens); put them in `~/.config/local/`.
- Never `stow */`: packages are stowed selectively per machine.
- Do not run `rebuild`/`update` yourself (sudo); tell the user the command.
- Only touch `nixos/flake.lock` through `update`.
- Commit messages: short, lowercase, imperative, no prefix (e.g. `add netbird to nix darwin`).
