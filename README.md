# dotfiles

Shell environment for any machine, including headless SSH hosts:
zsh, tmux, starship, nvim (LazyVim), btop, lazygit, fastfetch, git.

Desktop configs (Hyprland, Ghostty, `~/.zshrc.local`, …) live in `dotfiles-desktop`.

## Install

```bash
git clone https://github.com/HyperSoWeak/dotfiles ~/.dotfiles
~/.dotfiles/install.sh            # add --no-sudo to skip sudo entirely
```

| Machine | How tools are installed |
|---|---|
| Arch + sudo | `pacman` for everything |
| Debian/Ubuntu + sudo | `apt` for base packages and zsh; `mise` for CLI tools; tmux built from source |
| No sudo | zsh from [zsh-bin](https://github.com/romkatv/zsh-bin); `mise` for CLI tools; tmux built from source into `~/.local` |

Configs are symlinked from this repo; existing files are moved to `*.bak-<timestamp>`.

## Update

| Changed | Run on each machine |
|---|---|
| An existing config file | `git -C ~/.dotfiles pull` (configs are symlinks, so this is enough) |
| A new file in `LINKS`, a new tool, or a new tmux / zsh plugin release | `git -C ~/.dotfiles pull && ~/.dotfiles/install.sh` |
| Tool versions (non-pacman machines) | `mise up` |
| nvim plugin versions (`lazy-lock.json`) | `:Lazy restore` inside nvim |

Running programs need a reload: `exec zsh`, `prefix r` in tmux, restart nvim.

## Notes

- btop does not save settings on exit (`save_config_on_exit = false`), so changes made in its UI
  do not dirty this repo. Edit `btop/btop.conf` instead.
- tmux, starship, nvim and btop all use Catppuccin Macchiato.

## Per-machine overrides

`~/.zshrc.local` is sourced if present and is not tracked here.
