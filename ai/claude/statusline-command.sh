#!/usr/bin/env sh
input=$(cat)

# Extract fields
cwd=$(echo "$input"   | jq -r '.workspace.current_dir // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
effort=$(echo "$input"| jq -r '.effort.level // empty')
ctx=$(echo "$input"   | jq -r '.context_window.used_percentage // empty')
itok=$(echo "$input"  | jq -r '
  (.context_window.current_usage |
    if . == null then 0
    else (.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0)
    end) // 0')
fh=$(echo "$input"    | jq -r '.rate_limits.five_hour.used_percentage // empty')
sd=$(echo "$input"    | jq -r '.rate_limits.seven_day.used_percentage // empty')
branch=$(echo "$input"| jq -r '.worktree.branch // .workspace.git_worktree // empty')
[ -z "$branch" ] && [ -n "$cwd" ] && branch=$(git -C "$cwd" branch --show-current 2>/dev/null)

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YEL='\033[0;33m'
MAG='\033[0;35m'
DIM='\033[2m'
R='\033[0m'

sep="${DIM} | ${R}"
out=''

# group 1: dir [branch]
if [ -n "$cwd" ]; then
  loc="$(basename "$cwd")"
  [ -n "$branch" ] && loc="${loc} ${branch}"
  out="${CYAN}${loc}${R}"
fi

# group 2: model [effort]  (strip "Claude " prefix)
if [ -n "$model" ]; then
  m=$(echo "$model" | sed 's/^Claude //')
  [ -n "$effort" ] && m="${m} ${effort}"
  out="${out}${sep}${GREEN}${m}${R}"
fi

# group 3: token count + ctx%
if [ -n "$ctx" ]; then
  ci=$(printf '%.0f' "$ctx")
  tok_str=''
  if [ "$itok" -gt 0 ] 2>/dev/null; then
    if [ "$itok" -ge 1000000 ]; then
      tok_str=$(awk "BEGIN{printf \"%.1fM\", $itok/1000000}")
    elif [ "$itok" -ge 1000 ]; then
      tok_str=$(awk "BEGIN{printf \"%.0fK\", $itok/1000}")
    else
      tok_str="${itok}"
    fi
  fi
  usage="${tok_str:+${tok_str} }${ci}%"
  out="${out}${sep}${YEL}${usage}${R}"
fi

# group 4: rate limits
rate=''
[ -n "$fh" ] && rate="5h:$(printf '%.0f' "$fh")%"
[ -n "$sd" ] && rate="${rate:+${rate} }7d:$(printf '%.0f' "$sd")%"
[ -n "$rate" ] && out="${out}${sep}${MAG}${rate}${R}"

printf '%b' "$out"
