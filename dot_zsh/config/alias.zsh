# ================================
#  Aliases
# ================================
source ~/.zsh/config/guard.zsh

alias sudo='sudo '

alias ssh='TERM=xterm-256color ssh'
alias kali='distrobox enter kali'
alias_if_cmd zeditor zed 'zeditor'

# Prefer lsd when available; otherwise keep stock ls and provide portable flags.
if has lsd; then
  alias_if_cmd lsd ls 'lsd'
  alias_if_cmd lsd ll 'lsd -lh'
  alias_if_cmd lsd la 'lsd -lhA'
else
  alias ll='ls -lh'
  alias la='ls -lhA'
fi

# hyprlock helper
if has hyprctl && has hyprlock; then
  alias fix-hypr="hyprctl --instance 0 'keyword misc:allow_session_lock_restore 1'; hyprctl --instance 0 'dispatch exec hyprlock'"
fi

# Quick access helpers
alias ze='zed . && exit'
alias algo='zed ~/weak/algo/ && exit'
alias hw='zed ~/ntu/ntuhw && exit'
alias binja='binaryninja'

if has zeditor && has zellij; then
  alias owo='zed ~/proj/OwoJudge/ && zellij --layout ~/.config/zellij/layout/owojudge.kdl'
fi
