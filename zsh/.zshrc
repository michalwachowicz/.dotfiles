export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

plugins=(git)

source "$ZSH/oh-my-zsh.sh"

export EDITOR="nvim"
export VISUAL="nvim"
export GIT_EDITOR="nvim"

bindkey -v
bindkey -M viins 'jk' vi-cmd-mode

export KEYTIMEOUT=10

function zle-keymap-select {
  if [[ $KEYMAP == vicmd ]]; then
    printf '\e[1 q'
  else
    printf '\e[5 q'
  fi
}

function zle-line-init {
  printf '\e[5 q'
}

function zle-line-finish {
  printf '\e[5 q'
}

zle -N zle-keymap-select
zle -N zle-line-init
zle -N zle-line-finish

[ -d "/opt/homebrew/opt/libpq/bin" ] && export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
[ -d "/home/linuxbrew/.linuxbrew/opt/libpq/bin" ] && export PATH="/home/linuxbrew/.linuxbrew/opt/libpq/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

token() {
  local export_line
  export_line="$(command token --print-export 2>/dev/null)" || {
    echo "token executable not found in PATH or failed" >&2
    return 1
  }

  eval "$export_line"
  echo "TOKEN loaded (length: ${#TOKEN})"
}
