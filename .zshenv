# Path to oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load.
ZSH_THEME="robbyrussell"

# Oh-my-zsh plugins.
plugins=(git docker docker-compose mosh tmux gnu-utils vagrant
         zsh-autosuggestions zsh-syntax-highlighting)

export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"

# Operating system specific configuration.
if [[ "$(uname)" == "Darwin" ]]; then
    source "$HOME/.zshenv_mac"
elif [[ "$(expr substr $(uname -s) 1 5)" == "Linux" ]]; then
    source "$HOME/.zshenv_linux"
fi

source "$ZSH/oh-my-zsh.sh"

export LANG=en_US.UTF-8

# Set vi/vim/nvim as $EDITOR and $GIT_EDITOR
export EDITOR=vi
hash vim 2>/dev/null && {
    export EDITOR=vim
}
hash nvim 2>/dev/null && {
    export EDITOR=nvim
}
export GIT_EDITOR=$EDITOR

# Source aliases
test -f "$HOME/.aliases" || touch "$HOME/.aliases"
source "$HOME/.aliases"

# Load my autoenv plugin.
source "$HOME/.autoenv"

# Source machine specific configuration
test -f "$HOME/.my_zsh_profile" || touch "$HOME/.my_zsh_profile"
source "$HOME/.my_zsh_profile"
