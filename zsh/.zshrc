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
export SUDO_EDITOR=$(command -v nvim)
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
# Trailing space expands aliases after sudo (sudo ls -> sudo lsd)
alias sudo='sudo '

alias ls='lsd'
alias ll='lsd -lh'
alias la='lsd -lhA'

alias ff='fastfetch'
alias lg='lazygit'

# ------------------------------------------------------------------ Functions
# sudo's secure_path excludes mise shims, and a shim run as root reads root's mise config,
# so swap a shim for the real binary it points to. `function` form avoids expanding the
# sudo alias in the definition.
function sudo {
  if [[ ${commands[$1]} == */mise/shims/* ]]; then
    set -- "$(mise which "$1")" "${@:2}"
  fi
  command sudo "$@"
}

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

  # Output goes to /dev/null, so a typo would otherwise fail silently.
  whence -- "$1" >/dev/null || { echo "detach: command not found: $1"; return 127; }
  nohup "$@" >/dev/null 2>&1 &!
}

# Toggle passwordless sudo for the current user.
# Usage: nopasswd [on|off|status]   (no arg = toggle)
nopasswd() {
  local f=/etc/sudoers.d/10-nopasswd-$USER
  local cmd=${1:-toggle} rc

  # State is whether our file exists, not whether sudo asks for a password, since another
  # sudoers rule may also grant NOPASSWD. /etc/sudoers.d is root-only, but if the file
  # exists NOPASSWD is active, so `sudo -n test` can check it without prompting.
  if [[ $cmd == toggle ]]; then
    sudo -n test -e $f 2>/dev/null && cmd=off || cmd=on
  fi

  case $cmd in
    on)
      local tmp=$(mktemp)
      # verifypw=any lets `sudo -nv` (used by starship's sudo module) pass despite the
      # password-requiring %wheel rule, so the prompt shows the unlocked icon
      print -r -l -- "Defaults:$USER verifypw=any" "$USER ALL=(ALL:ALL) NOPASSWD: ALL" > $tmp
      # Validate before installing; a broken sudoers file can lock you out of sudo
      sudo visudo -cqf $tmp && sudo install -m 0440 -o root -g root $tmp $f
      rc=$?
      rm -f $tmp
      (( rc == 0 )) || return $rc
      ;;
    off)
      sudo rm -f $f && sudo -k || return
      ;;
    status) ;;
    *)
      print -u2 "usage: nopasswd [on|off|status]"
      return 1
      ;;
  esac

  if sudo -n test -e $f 2>/dev/null; then
    print "passwordless sudo: ON"
  # -k ignores cached credentials, so this only succeeds when some rule grants NOPASSWD
  elif sudo -kn true 2>/dev/null; then
    print "passwordless sudo: OFF (another sudoers rule still grants NOPASSWD)"
  else
    print "passwordless sudo: OFF"
  fi
}

# Pull dotfiles, re-run install.sh (links, packages, zsh plugins), upgrade mise tools,
# sync nvim plugins to lazy-lock.json, then reload zsh. Args go to install.sh.
updot() {
  local dotfiles="$HOME/.dotfiles" dirty
  # Lazy rewrites the lockfile on local updates; restore below resets it to the repo's anyway.
  git -C "$dotfiles" checkout -- nvim/lazy-lock.json || return
  dirty=$(git -C "$dotfiles" status --porcelain --untracked-files=no) || return
  if [[ -n $dirty ]]; then
    print -u2 "updot: local changes in $dotfiles; commit, stash or discard them first:"
    print -u2 -- "$dirty"
    return 1
  fi
  git -C "$dotfiles" pull --ff-only || return
  "$dotfiles/install.sh" "$@" || return
  if command -v mise >/dev/null; then
    mise up || return
  fi
  nvim --headless '+Lazy! restore' +qa || return
  exec zsh
}

# ---------------------------------------------------------- Optional profiles
# A machine may opt into the tracked daily profile from ~/.zshrc.local:
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# Must remain last because it wraps every widget defined above and by profiles.
source "$ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

true
