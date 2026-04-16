# ================================
#  PATH Settings
# ================================
source ~/.zsh/config/guard.zsh

export EDITOR=nvim

export PATH="$HOME/.local/bin:$PATH"
export PATH="/opt/nvim-linux-x86_64/bin:$PATH"
export PATH="/home/hyper/.deno/bin:$PATH"
export PATH="/usr/bin/vendor_perl:$PATH"
export PATH="/home/hyper/.local/share/gem/ruby/3.4.0/bin:$PATH"
export PATH="/home/hyper/utils/bin:$PATH"

# PNPM
export PNPM_HOME="/home/hyper/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"

# NVM
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && . "$NVM_DIR/bash_completion"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
[[ -d "$PYENV_ROOT/bin" ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval_if_cmd pyenv 'eval "$(pyenv init - zsh)"'
eval_if_cmd pyenv 'eval "$(pyenv virtualenv-init -)"'

export PYTHONPATH="/usr/lib/python3.13/site-packages:$PYTHONPATH"

# tps
export TPS_TASK_TEMPLATES_PATH="/home/hyper/.local/share/tps/task-templates"
