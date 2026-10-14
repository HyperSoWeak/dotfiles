# dotfiles

Shell environment for any machine, including headless SSH hosts:
zsh, tmux, starship, nvim (LazyVim), btop, lazygit, fastfetch, git.

Desktop configs (Hyprland, Ghostty, `~/.zshrc.local`, …) live in `dotfiles-desktop`.

## Install

```bash
git clone https://github.com/<you>/dotfiles ~/.dotfiles
~/.dotfiles/install.sh            # add --no-sudo to skip sudo entirely
```

| Machine | How tools are installed |
|---|---|
| Arch + sudo | `pacman` for everything |
| Debian/Ubuntu + sudo | `apt` for base packages and zsh; `mise` for CLI tools; tmux built from source |
| No sudo | zsh from [zsh-bin](https://github.com/romkatv/zsh-bin); `mise` for CLI tools; tmux built from source into `~/.local` |

Configs are symlinked from this repo; existing files are moved to `*.bak-<timestamp>`.

## Update

```bash
git -C ~/.dotfiles pull && ~/.dotfiles/install.sh
mise up                           # non-pacman machines
```

## Per-machine overrides

`~/.zshrc.local` is sourced if present and is not tracked here.
