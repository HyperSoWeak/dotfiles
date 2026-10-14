#!/usr/bin/env bash
# Check that every tool runs and the configs load. Run inside a test container.

set -euo pipefail
export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"

for cmd in zsh tmux nvim btop lazygit fzf rg fd starship zoxide lsd fastfetch; do
    printf '%-10s %s\n' "$cmd" "$("$cmd" --version 2>&1 | head -1)"
done

tmux -L test -f /dev/null new-session -d
tmux -L test source-file ~/.config/tmux/tmux.conf
tmux -L test kill-server
echo "tmux.conf  ok"

zsh -i -c 'echo "zshrc      ok"'
