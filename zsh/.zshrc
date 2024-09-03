# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

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

# Load completions
# autoload -Uz compinit && compinit

# History management
zinit cdreplay -q

bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

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
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa --tree --icons --level=1 -a $realpath'
zstyle ':fzf-tab:complete:z:*' fzf-preview 'exa --tree --icons --level=1 -a $realpath'


# Base
alias c="clear"
alias ls="exa --tree --icons --level=1 -a"
alias lt="exa --tree --icons --level=2 -a"
alias grep="grep --color=auto"
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"

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

# Conda
if command -v brew &> /dev/null; then
    __conda_setup="$('/opt/homebrew/Caskroom/miniconda/base/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
            . "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh"
        else
            export PATH="/opt/homebrew/Caskroom/miniconda/base/bin:$PATH"
        fi
    fi
    unset __conda_setup
fi

# Tmux
alias tx=tmuxinator

# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init zsh)"
alias zscore="zoxide query --list --score"

# Oh my posh
eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/zen.toml)"
