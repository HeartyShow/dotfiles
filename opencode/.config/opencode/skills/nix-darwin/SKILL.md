---
name: nix-darwin
description: Managing Nix and nix-darwin system configuration on macOS, NixOS on Linux
---

# Nix System Management

This user manages system packages and configuration through Nix flakes.

## Key concepts
- Flake is at `~/.dotfiles/nixos/flake.nix`.
- On macOS: uses nix-darwin, rebuild with `rebuild()` shell function.
- On NixOS: uses nixos-rebuild, rebuild with `rebuild()` shell function.
- The `rebuild()` function detects the OS and runs the appropriate command.

## Rules
- NEVER use `brew install`, `apt install`, `pacman -S`, or any manual package installation for system tools.
- To add a system package: edit `flake.nix` and run `rebuild()`.
- To add a dev tool scoped to a project: add it to the project's `.mise.toml`, not the system config.
- Nix is declarative -- all system state comes from the flake.
- When editing flake.nix, follow the existing structure and formatting.
