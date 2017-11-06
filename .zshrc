# Load zplug
source ~/.zplug/init.zsh

#####################
#      Plugins
#####################
zplug "lib/clipboard", from:oh-my-zsh
zplug "lib/completion", from:oh-my-zsh
zplug "lib/history", from:oh-my-zsh
zplug "lib/key-bindings", from:oh-my-zsh
zplug "lukechilds/zsh-nvm"
zplug "plugins/brew-cask", from:oh-my-zsh, if:"[[ $OSTYPE == *darwin* ]]"
zplug "plugins/docker", from:oh-my-zsh
zplug "plugins/docker-compose", from:oh-my-zsh
zplug "plugins/git", from:oh-my-zsh
zplug "plugins/gnu-utils", from:oh-my-zsh
zplug "plugins/lein", from:oh-my-zsh
zplug "plugins/osx", from:oh-my-zsh, if:"[[ $OSTYPE == *darwin* ]]"
zplug "plugins/terminalapp", from:oh-my-zsh, if:"[[ $OSTYPE == *darwin* ]]"
zplug "plugins/tmux", from:oh-my-zsh
zplug 'zplug/zplug', hook-build:'zplug --self-manage'
zplug "zsh-users/zsh-autosuggestions", defer:2
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-syntax-highlighting", defer:2

zplug 'dracula/zsh', as:theme

zplug load

# Operating system specific configuration.
if [[ "$(uname)" == "Darwin" ]]; then
    source "$HOME/.zshrc_mac"
elif [[ "$(expr substr $(uname -s) 1 5)" == "Linux" ]]; then
    source "$HOME/.zshrc_linux"
fi

# Source aliases
test -f "$HOME/.aliases" || touch "$HOME/.aliases"
source "$HOME/.aliases"

# Source machine specific configuration
test -f "$HOME/.my_zsh_profile" || touch "$HOME/.my_zsh_profile"
source "$HOME/.my_zsh_profile"
