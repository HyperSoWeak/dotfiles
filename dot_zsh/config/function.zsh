# ================================
#  Functions
# ================================
source ~/.zsh/config/guard.zsh

# Create a directory and enter it immediately.
mkcd() {
  if (( $# != 1 )); then
    echo "usage: mkcd <directory>"
    return 1
  fi

  mkdir -p "$1" && cd "$1"
}

# Activate the current directory's virtualenv when it exists.
venv() {
  if [[ ! -f .venv/bin/activate ]]; then
    echo "venv: .venv/bin/activate not found in $(pwd)"
    return 1
  fi

  source .venv/bin/activate
}

# Launch VS Code with Wayland flags when the binary exists.
code() {
  if [[ ! -x /usr/bin/code ]]; then
    echo "code: /usr/bin/code is not installed" >&2
    return 127
  fi

  /usr/bin/code "$@" \
    --enable-features=UseOzonePlatform \
    --ozone-platform=wayland \
    --enable-wayland-ime \
    2>/dev/null
}

# Open the given path in Nautilus without blocking the shell.
exp() {
  local target="${1:-.}"

  if ! require_cmds nautilus; then
    return 127
  fi

  nautilus "$target" >/dev/null 2>&1 &
  disown
}

# Start the local pwn environment and attach the Zellij layout.
pp() {
  if ! require_cmds docker zellij; then
    return 127
  fi

  export PP_PWNDBG_ARGS="$*"

  docker compose ps -q | grep -q . || docker compose up -d
  docker compose exec -u 0 chal sh -c "pkill -9 -f chal" || true
  docker compose exec -u 0 chal sh -c "pkill -9 -f gdbserver" || true
  docker compose exec -u 0 chal sh -c "pkill -9 -f bash" || true

  zellij --layout ~/.config/zellij/layout/pwn.kdl
}

# Run a command fully detached from the current shell.
# Usage:
#   detach command [args...]
#   detach ./app
#   detach python server.py
detach() {
  if (( $# == 0 )); then
    echo "usage: detach <command> [args...]"
    return 1
  fi

  if ! require_cmds nohup; then
    return 127
  fi

  nohup "$@" > /dev/null 2>&1 & disown
}
