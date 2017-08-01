# Load antigen
source "$HOME/antigen.zsh"

# Use oh-my-zsh library
antigen use oh-my-zsh

export NVM_LAZY_LOAD=true

# Plugins
antigen bundle docker
antigen bundle docker-compose
antigen bundle git
antigen bundle gnu-utils
antigen bundle lein
antigen bundle lukechilds/zsh-nvm
antigen bundle tmux
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-autosuggestions

antigen theme robbyrussell

export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"

# Operating system specific configuration.
if [[ "$(uname)" == "Darwin" ]]; then
    source "$HOME/.zshenv_mac"
elif [[ "$(expr substr $(uname -s) 1 5)" == "Linux" ]]; then
    source "$HOME/.zshenv_linux"
fi

antigen apply

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

# Source machine specific configuration
test -f "$HOME/.my_zsh_profile" || touch "$HOME/.my_zsh_profile"
source "$HOME/.my_zsh_profile"
