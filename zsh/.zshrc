# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

export XDG_CONFIG_HOME="$HOME/.config"

# ── Machine-local config overrides (~/.config/local/) ─────────
# Lazygit: merge local config if it exists
LG_LOCAL="$HOME/.config/local/lazygit.yml"
if [ -f "$LG_LOCAL" ]; then
  export LG_CONFIG_FILE="$HOME/.config/lazygit/config.yml,$LG_LOCAL"
fi
unset LG_LOCAL

# OpenCode: load device-specific config if it exists
OC_LOCAL="$HOME/.config/local/opencode.json"
if [ -f "$OC_LOCAL" ]; then
  export OPENCODE_CONFIG="$OC_LOCAL"
fi
unset OC_LOCAL

# Sheldon zsh package manager
if command -v sheldon >/dev/null 2>&1; then
  eval "$(sheldon source)"
fi

TPM_DIR="${HOME}/.tmux/plugins/tpm"

# Download TPM, if it's not there yet
if [ ! -d "$TPM_DIR" ]; then
   mkdir -p "$(dirname "$TPM_DIR")"
   git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

TMUX_CATPPUCCIN_DIR="${HOME}/.tmux/plugins/catppuccin"

# Download Tmux catppuccin, if it's not there yet
if [ ! -d "$TMUX_CATPPUCCIN_DIR" ]; then
   mkdir -p "$(dirname "$TMUX_CATPPUCCIN_DIR")"
   git clone -b v2.1.3 https://github.com/catppuccin/tmux.git "$TMUX_CATPPUCCIN_DIR"
fi

# Download Bat Catppuccin Mocha theme, if it's not there yet
if command -v bat >/dev/null 2>&1; then
   BAT_THEME_DIR="$(bat --config-dir)/themes"
   BAT_MOCHA_THEME="${BAT_THEME_DIR}/Catppuccin Mocha.tmTheme"
   if [ ! -f "$BAT_MOCHA_THEME" ]; then
      mkdir -p "$BAT_THEME_DIR"
      curl -fsSLo "$BAT_MOCHA_THEME" "https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Mocha.tmTheme"
      bat cache --build
   fi
fi

autoload -Uz compinit
compinit

HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
export FZF_DEFAULT_OPTS=" \
    --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
    --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
    --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
    --color=selected-bg:#45475a \
    --multi"

preview_ls_cmd='eza --tree --icons --level=1 -a'

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':fzf-tab:complete:*' fzf-flags $(echo $FZF_DEFAULT_OPTS)
zstyle ':fzf-tab:complete:ls:*' fzf-preview $preview_ls_cmd '$realpath'
zstyle ':fzf-tab:complete:cd:*' fzf-preview $preview_ls_cmd '$realpath'
zstyle ':fzf-tab:complete:z:*' fzf-preview $preview_ls_cmd '$realpath'
zstyle ':fzf-tab:complete:nvim:*' fzf-preview 'bat $realpath 2>/dev/null ||' $preview_ls_cmd '$realpath'
zstyle ':fzf-tab:complete:vim:*' fzf-preview 'bat $realpath 2>/dev/null ||' $preview_ls_cmd '$realpath'

# Base
alias c="clear"
alias ls="eza --tree --icons --level=1 -a"
alias lt="eza --tree --icons --level=2 -a"
alias grep="grep --color=auto"

# Zsh
export ZSHRC="$HOME/.zshrc"

#Nvim
export NVIM_DIR="$HOME/.config/nvim"
export EDITOR="nvim"

# Tmux
alias tx=tmuxinator

# Bare clone a repo into ~/Documents/dev/<repo> with a main worktree
clone() {
  local url="$1"
  if [ -z "$url" ]; then
    echo "Usage: clone <git-url>" >&2
    return 1
  fi
  local repo=$(basename "$url" .git)
  local dest="$HOME/Documents/dev/$repo"
  if [ -d "$dest" ]; then
    echo "Already exists: $dest" >&2
    return 1
  fi
  git clone --bare "$url" "$dest/.git" \
    && git -C "$dest" config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*' \
    && git -C "$dest" fetch origin \
    && wt switch --no-cd main -C "$dest"
}

# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init zsh)"
eval "$(tv init zsh)"
eval "$(wt config shell init zsh)"
eval "$(mise activate zsh)"
alias zscore="zoxide query --list --score"

# Oh my posh
eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/zen.toml)"

# Nixos
if [ -d /etc/NIXOS ] || command -v nixos-version >/dev/null 2>&1; then
  rebuild() {
    local flake_path="path:$HOME/.dotfiles/nixos"
    if [ -n "$1" ]; then
      flake_path="${flake_path}#$1"
    fi
    sudo nixos-rebuild switch --flake "$flake_path" --impure
  }
fi

# Cargo/Rust
if command -v cargo >/dev/null 2>&1; then
  export CARGO_HOME="${CARGO_HOME:-$HOME/.cargo}"
  export PATH="$CARGO_HOME/bin:$PATH"
fi

# Go
if command -v go >/dev/null 2>&1; then
  export GOPATH="${GOPATH:-$HOME/go}"
  export PATH="$GOPATH/bin:$PATH"
fi

# GPG signatures
export GPG_TTY=$(tty)

alias buildx="docker-buildx"
