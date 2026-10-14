#!/usr/bin/env bash
# Run install.sh in fresh containers and check the result.
# Each case logs to test/logs/<case>.log.
#
# Usage: test/docker.sh [case...]   (default: all)
#   ubuntu-root     Ubuntu 24.04 as root (apt + mise + tmux build)
#   ubuntu-nosudo   Ubuntu 24.04 as a user without sudo (zsh-bin + mise + tmux build)
#   debian-root     Debian 12 as root
#   arch-root       Arch as root (pacman)

set -uo pipefail

DOTFILES=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
LOGS="$DOTFILES/test/logs"
mkdir -p "$LOGS"

# Higher GitHub API rate limit for mise and build-tmux.sh.
token=$(gh auth token 2>/dev/null || true)

run_case() {
    local name=$1 image setup user=root flags=""
    case $name in
        ubuntu-root) image=ubuntu:24.04 setup="apt-get update -q && apt-get install -yq git" ;;
        debian-root) image=debian:12 setup="apt-get update -q && apt-get install -yq git" ;;
        arch-root) image=archlinux:latest setup="pacman -Syu --noconfirm git" ;;
        ubuntu-nosudo)
            image=ubuntu:24.04
            setup="apt-get update -q && apt-get install -yq git curl unzip build-essential && useradd -m u"
            user=u flags=--no-sudo
            ;;
        *) echo "unknown case: $name" >&2; return 1 ;;
    esac

    local home=/root
    [[ $user != root ]] && home=/home/$user

    if docker run --rm -v "$DOTFILES:/src:ro" "$image" bash -ec "
        $setup
        runuser -u $user -- env HOME=$home USER=$user GITHUB_TOKEN=$token bash -ec '
            cp -r /src ~/.dotfiles
            rm -rf ~/.dotfiles/test/logs
            ~/.dotfiles/install.sh $flags
            echo ===== verify
            ~/.dotfiles/test/verify.sh
        '" >"$LOGS/$name.log" 2>&1; then
        echo "PASS $name"
    else
        echo "FAIL $name (see test/logs/$name.log)"
    fi
}

cases=("$@")
(( ${#cases[@]} )) || cases=(ubuntu-root ubuntu-nosudo debian-root arch-root)

for c in "${cases[@]}"; do
    run_case "$c" &
done
wait
