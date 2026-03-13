export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

plugins=(git)

source "$ZSH/oh-my-zsh.sh"

# Enable Vim Mode
bindkey -v
bindkey -M viins 'jk' vi-cmd-mode

function zle-keymap-select {
    if [[ ${KEYMAP} == vicmd ]]; then
        echo -ne "\e[1 q"
    else
        echo -ne "\e[5 q"
    fi
}

zle -N zle-keymap-select

[ -d "/opt/homebrew/opt/libpq/bin" ] && export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
[ -d "/home/linuxbrew/.linuxbrew/opt/libpq/bin" ] && export PATH="/home/linuxbrew/.linuxbrew/opt/libpq/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
