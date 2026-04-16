# ================================
#  Guard Helpers
# ================================
if [[ -n "${__HYPER_ZSH_GUARD_LOADED:-}" ]]; then
  return 0
fi

readonly __HYPER_ZSH_GUARD_LOADED=1

# Return success when the given command exists in PATH.
has() {
  command -v "$1" >/dev/null 2>&1
}

# Ensure all commands exist; otherwise print one compact error.
require_cmds() {
  local caller="${funcstack[2]:-${funcstack[1]:-shell}}"
  local missing=()
  local cmd

  for cmd in "$@"; do
    has "$cmd" || missing+=("$cmd")
  done

  if (( ${#missing[@]} > 0 )); then
    echo "${caller}: missing command(s): ${missing[*]}" >&2
    return 127
  fi
}

# Source a file only when it exists and is readable.
source_if_exists() {
  [[ -r "$1" ]] && source "$1"
}

# Run a command string only when the named command exists.
eval_if_cmd() {
  local cmd="$1"
  local body="$2"

  has "$cmd" && eval "$body"
}

# Define an alias only when the named command exists.
alias_if_cmd() {
  local cmd="$1"
  local name="$2"
  local value="$3"

  has "$cmd" && alias "${name}=${value}"
}
