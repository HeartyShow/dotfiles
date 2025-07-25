# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

export XDG_CONFIG_HOME="$HOME/.config"

# Zinit package manager
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

autoload -Uz compinit
compinit

# Plugins installation
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit ice depth=1; zinit light jeffreytse/zsh-vi-mode
zinit light fourdim/zsh-poetry
zinit wait lucid for MichaelAquilina/zsh-autoswitch-virtualenv

# Load completions
# autoload -Uz compinit && compinit

# History management
zinit cdreplay -q

bindkey '^k' history-search-backward
bindkey '^j' history-search-forward

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

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --tree --icons --level=1 -a $realpath'
zstyle ':fzf-tab:complete:z:*' fzf-preview 'eza --tree --icons --level=1 -a $realpath'
zstyle ':fzf-tab:complete:nvim:*' fzf-preview 'bat --color=always --style=numbers $realpath 2>/dev/null || eza --tree --icons --level=1 --color=always $realpath'

# Base
alias c="clear"
alias ls="eza --tree --icons --level=1 -a"
alias lt="eza --tree --icons --level=2 -a"
alias grep="grep --color=auto"

# Android
alias android="scrcpy --video-bit-rate=50M"

# CD shortcuts
alias dev="cd ~/documents/dev"

# Zsh
export ZSHRC="$HOME/.zshrc"
alias zshedit="nvim $ZSHRC"
alias zshsource="source $ZSHRC"
zshsave(){echo "Saving ..." && git -C ~ add -u && git -C ~ commit -qm "$1" && git -C ~ push -q && zshsource}

# Git
alias gittree="git log --graph --oneline --decorate --all"

# Stow
alias stowtest="docker run -ti \
-v ~/.dotfiles:/root/stow \
registry.gitlab.com/waterkip/stowing:latest zsh"

#Nvim
export NVIM_DIR="$HOME/.config/nvim"
export EDITOR="nvim"
alias nvimdir="cd $NVIM_DIR"
alias nvimconfig="cd $NVIM_DIR"
nvimconfsave(){echo "Saving..." && git -C $NVIM_DIR add -A && git -C $NVIM_DIR commit -qm "$1" && git -C $NVIM_DIR push -q}

# Tmux
alias tx=tmuxinator

# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init zsh)"
alias zscore="zoxide query --list --score"

# Oh my posh
eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/zen.toml)"

# Tmux Sesh extension
function sesh-sessions() {
  {
    exec </dev/tty
    exec <&1
    local session
    session=$(sesh list -t -c | fzf --height 40% --reverse --border-label ' sesh ' --border --prompt '⚡  ')
    [[ -z "$session" ]] && return
    sesh connect $session
  }
}

zle     -N             sesh-sessions
bindkey -M emacs '\es' sesh-sessions
bindkey -M vicmd '\es' sesh-sessions
bindkey -M viins '\es' sesh-sessions

# Nixos
if [ -d /etc/NIXOS ] || command -v nixos-version >/dev/null 2>&1; then
  # Add an alias to rebuild the NixOS configuration
  alias rebuild='sudo nixos-rebuild switch --flake path:$HOME/.dotfiles/nixos --impure'
fi

# PyEnv auto-completion
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ] && \. "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" # This loads nvm
[ -s "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" 


# Created by `pipx` on 2024-11-14 09:21:31
export PATH="$PATH:/Users/I584830/.local/bin"

# GPG signatures
export GPG_TTY=$(tty)

alias buildx="docker-buildx"

eval "$(pyenv virtualenv-init -)"

