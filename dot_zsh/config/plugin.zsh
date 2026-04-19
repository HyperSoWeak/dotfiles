# ================================
#  Plugins
# ================================
source ~/.zsh/config/guard.zsh

# completion system
zstyle :compinstall filename '/home/hyper/.zshrc'
autoload -Uz compinit
compinit

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

# zsh plugins
source_if_exists ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source_if_exists ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
eval_if_cmd fzf 'source <(fzf --zsh)'

# UI / prompt
eval_if_cmd starship 'eval "$(starship init zsh)"'
eval_if_cmd zoxide 'eval "$(zoxide init zsh)"'

# fastfetch at shell startup
eval_if_cmd fastfetch-smart 'fastfetch-smart'
