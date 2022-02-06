# Load zplug
source ~/.zplug/init.zsh

#####################
#      Plugins
#####################

# nvm plugin just kept here for installation only. Loaded in zshenv so its
# available for non-interactive shells.
# zplug "lukechilds/zsh-nvm"
#

zplug "lib/clipboard", from:oh-my-zsh
zplug "lib/completion", from:oh-my-zsh
zplug "lib/history", from:oh-my-zsh
zplug "lib/key-bindings", from:oh-my-zsh
zplug "plugins/bazel", from:oh-my-zsh
zplug "plugins/docker", from:oh-my-zsh
zplug "plugins/git", from:oh-my-zsh
zplug "plugins/gnu-utils", from:oh-my-zsh
zplug "plugins/macos", from:oh-my-zsh, if:"[[ $OSTYPE == *darwin* ]]"
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
LOCAL_ZSHRC="$HOME/.zshrc_local"
test -f "$LOCAL_ZSHRC" || touch "$LOCAL_ZSHRC"
source "$LOCAL_ZSHRC"

# Base16 Shell
# https://github.com/chriskempson/base16-shell
BASE16_SHELL="$HOME/.config/base16-shell/"
[ -n "$PS1" ] && \
    [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
        eval "$("$BASE16_SHELL/profile_helper.sh")"
