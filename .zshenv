# Path to oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load.
ZSH_THEME="af-magic"

# Oh-my-zsh plugins.
plugins=(git docker docker-compose mosh tmux gnu-utils vagrant
         zsh-autosuggestions zsh-syntax-highlighting)

# Operating system specific configuration.
if [[ "$(uname)" == "Darwin" ]]; then
    source "$HOME/.zshrc_osx"
elif [[ "$(expr substr $(uname -s) 1 5)" == "Linux" ]]; then
    source "$HOME/.zshrc_linux"
elif [[ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]]; then
    # Do something under Windows NT platform
fi

export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"

source "$ZSH/oh-my-zsh.sh"

export LANG=en_US.UTF-8

export EDITOR=vi

alias config='git --git-dir=$HOME/.myconf/ --work-tree=$HOME'

# Use vim instead of vi if it exists.
hash vim 2>/dev/null && {
    export EDITOR=vim
    alias vi=vim
}

# Use neovim instead of vim if it exists.
hash nvim 2>/dev/null && {
    export EDITOR=nvim
    alias vi=nvim
    alias vim=nvim
}

export GIT_EDITOR=$EDITOR

alias compose=docker-compose
# Clean up untagged images.
docker-clean-images () {
    docker rmi $(docker images -qf "dangling=true") 2> /dev/null
}

# List docker machines.
alias dml="docker-machine ls"
# Load docker-machine envs.
dme () {
    eval "$(docker-machine env $1)" 2> /dev/null
}

# Load my autoenv plugin.
source "$HOME/.autoenv"

# Source machine specific configuration
test -f "$HOME/.my_zsh_profile" || touch "$HOME/.my_zsh_profile"
source "$HOME/.my_zsh_profile"
