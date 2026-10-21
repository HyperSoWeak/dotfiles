# ==============================================================================
# Core shell configuration
# ==============================================================================

# --------------------------------------------------------------------- History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

setopt INC_APPEND_HISTORY_TIME
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
unsetopt beep

# ---------------------------------------------------------------- Environment
export EDITOR=nvim
export VISUAL=nvim

typeset -U path PATH
# mise shims: tools installed by mise on machines without pacman.
path=("$HOME/.local/bin" "$HOME/.local/share/mise/shims" $path)

ZSH_PLUGINS="$HOME/.config/zsh/plugins"

# -------------------------------------------------------------------- Vi mode
export KEYTIMEOUT=1
ZVM_INIT_MODE=sourcing
ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
source "$ZSH_PLUGINS/zsh-vi-mode/zsh-vi-mode.plugin.zsh"

# ---------------------------------------------------------------- Keybindings
# Make ^W stop at path separators and ^[w delete a complete path component.
WORDCHARS="${WORDCHARS//\//}"

backward-kill-path() {
  local WORDCHARS="${WORDCHARS}/"
  zle backward-kill-word
}
zle -N backward-kill-path
bindkey '^[w' backward-kill-path

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

# ---------------------------------------------------------------- Completion
autoload -Uz compinit
_zcompdump_stale=("$HOME"/.zcompdump(N.mh+24))
if (( $#_zcompdump_stale )) || [[ ! -f "$HOME/.zcompdump" ]]; then
  compinit
else
  compinit -C
fi
unset _zcompdump_stale

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# ---------------------------------------------------------- Plugins and prompt
source "$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh"
source <(fzf --zsh)
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

# -------------------------------------------------------------------- Aliases
alias sudo='sudo '

alias ls='lsd'
alias ll='lsd -lh'
alias la='lsd -lhA'

alias ff='fastfetch'

# ------------------------------------------------------------------ Functions
mkcd() {
  if (( $# != 1 )); then
    echo "usage: mkcd <directory>"
    return 1
  fi

  mkdir -p "$1" && cd "$1"
}

venv() {
  if [[ ! -f .venv/bin/activate ]]; then
    echo "venv: .venv/bin/activate not found in $(pwd)"
    return 1
  fi

  source .venv/bin/activate
}

detach() {
  if (( $# == 0 )); then
    echo "usage: detach <command> [args...]"
    return 1
  fi

  nohup "$@" >/dev/null 2>&1 & disown
}

# ---------------------------------------------------------- Optional profiles
# A machine may opt into the tracked daily profile from ~/.zshrc.local:
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# Must remain last because it wraps every widget defined above and by profiles.
source "$ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

true
