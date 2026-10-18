#!/usr/bin/env bash
# Set up the shell environment on a new machine (Arch, Debian, Ubuntu; with or without sudo).
# Safe to re-run: installed tools are skipped and existing files are backed up before linking.
#
# Usage: ./install.sh [--no-sudo]

set -euo pipefail

DOTFILES=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

PACMAN_PACKAGES=(zsh git curl unzip base-devel tmux neovim btop lazygit fzf ripgrep fd starship zoxide lsd fastfetch)
APT_PACKAGES=(zsh git curl ca-certificates tar unzip build-essential)

ZSH_PLUGINS=(
    https://github.com/jeffreytse/zsh-vi-mode
    https://github.com/zsh-users/zsh-autosuggestions
    https://github.com/zsh-users/zsh-syntax-highlighting
)

# repo path -> target path
LINKS=(
    "zsh/.zshrc:$HOME/.zshrc"
    "tmux/tmux.conf:$HOME/.config/tmux/tmux.conf"
    "starship/starship.toml:$HOME/.config/starship.toml"
    "nvim:$HOME/.config/nvim"
    "btop/btop.conf:$HOME/.config/btop/btop.conf"
    "btop/themes/catppuccin_macchiato.theme:$HOME/.config/btop/themes/catppuccin_macchiato.theme"
    "lazygit/config.yml:$HOME/.config/lazygit/config.yml"
    "fastfetch/config.jsonc:$HOME/.config/fastfetch/config.jsonc"
    "git/.gitconfig:$HOME/.gitconfig"
    "mise/config.toml:$HOME/.config/mise/config.toml"
    "bin/tmux-sessionizer:$HOME/.local/bin/tmux-sessionizer"
)

log() { printf '\033[1;35m==>\033[0m %s\n' "$*"; }
die() { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

# ------------------------------------------------------------------ Detection
use_sudo=1
[[ ${1:-} == --no-sudo ]] && use_sudo=0

if (( EUID == 0 )); then
    SUDO=()
elif (( use_sudo )) && command -v sudo >/dev/null && sudo -v 2>/dev/null; then
    SUDO=(sudo)
else
    use_sudo=0
fi

. /etc/os-release
case " $ID ${ID_LIKE:-} " in
    *" arch "*) distro=arch ;;
    *" debian "* | *" ubuntu "*) distro=debian ;;
    *) die "unsupported distro: $ID" ;;
esac

log "distro=$distro sudo=$use_sudo"
mkdir -p "$HOME/.local/bin" "$HOME/.config"
export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"

# -------------------------------------------------------------------- Links
backup_suffix=".bak-$(date +%Y%m%d-%H%M%S)"
for entry in "${LINKS[@]}"; do
    src="$DOTFILES/${entry%%:*}"
    dst="${entry#*:}"
    [[ -L $dst && $(readlink "$dst") == "$src" ]] && continue
    dir=$(dirname "$dst")
    # A directory linked by an older LINKS entry would make $dst resolve into this repo.
    if [[ -L $dir ]]; then
        mv "$dir" "$dir$backup_suffix"
        log "backup $dir -> $dir$backup_suffix"
    fi
    mkdir -p "$dir"
    if [[ -e $dst || -L $dst ]]; then
        mv "$dst" "$dst$backup_suffix"
        log "backup $dst -> $dst$backup_suffix"
    fi
    ln -s "$src" "$dst"
    log "link $dst"
done

# ----------------------------------------------------------------- Packages
if (( use_sudo )) && [[ $distro == arch ]]; then
    log "pacman: ${PACMAN_PACKAGES[*]}"
    "${SUDO[@]}" pacman -Syu --needed --noconfirm "${PACMAN_PACKAGES[@]}"
else
    if (( use_sudo )); then
        log "apt: ${APT_PACKAGES[*]}"
        "${SUDO[@]}" apt-get update -q
        "${SUDO[@]}" env DEBIAN_FRONTEND=noninteractive apt-get install -yq "${APT_PACKAGES[@]}"
    else
        missing=()
        for cmd in git curl tar unzip cc make; do
            command -v "$cmd" >/dev/null || missing+=("$cmd")
        done
        (( ${#missing[@]} == 0 )) || die "missing without sudo: ${missing[*]}"
    fi

    if ! command -v zsh >/dev/null; then
        log "zsh-bin -> ~/.local"
        sh -c "$(curl -fsSL --retry 3 --retry-all-errors https://raw.githubusercontent.com/romkatv/zsh-bin/master/install)" -- -q -d "$HOME/.local" -e no
    fi

    if ! command -v mise >/dev/null; then
        log "mise"
        curl -fsSL --retry 3 --retry-all-errors https://mise.run | MISE_INSTALL_PATH="$HOME/.local/bin/mise" sh
    fi
    log "mise tools"
    MISE_YES=1 mise install

    "$DOTFILES/scripts/build-tmux.sh"
fi

# -------------------------------------------------------------- Zsh plugins
plugin_dir="$HOME/.config/zsh/plugins"
mkdir -p "$plugin_dir"
for url in "${ZSH_PLUGINS[@]}"; do
    dir="$plugin_dir/$(basename "$url")"
    if [[ -d $dir/.git ]]; then
        git -C "$dir" pull -q --ff-only
    else
        git clone -q --depth 1 "$url" "$dir"
    fi
done
log "zsh plugins up to date"

# ------------------------------------------------------------- Login shell
zsh_path=$(command -v zsh)
if [[ $(getent passwd "$USER" | cut -d: -f7) != */zsh ]]; then
    if (( use_sudo )) && grep -qx "$zsh_path" /etc/shells; then
        "${SUDO[@]}" chsh -s "$zsh_path" "$USER"
        log "login shell -> $zsh_path"
    elif ! grep -q '# dotfiles: exec zsh' "$HOME/.bashrc" 2>/dev/null; then
        # chsh needs root or a zsh listed in /etc/shells; hand off from bash instead.
        printf '\n# dotfiles: exec zsh\n[ -t 1 ] && [ -x "%s" ] && exec "%s" -l\n' "$zsh_path" "$zsh_path" >>"$HOME/.bashrc"
        log "bash -> exec zsh via ~/.bashrc"
    fi
fi

log "done. start a new shell, then open nvim once to install plugins."
