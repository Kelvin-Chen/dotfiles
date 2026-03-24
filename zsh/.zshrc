# Bootstrap zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

#####################
#      Plugins
#####################

# Oh-my-zsh libs
zinit snippet OMZL::clipboard.zsh
fpath=(~/.zsh/completions $fpath)
zinit snippet OMZL::completion.zsh
zinit snippet OMZL::history.zsh
zinit snippet OMZL::key-bindings.zsh

# Oh-my-zsh plugins
zinit snippet OMZP::git
zinit snippet OMZP::gnu-utils
zinit snippet OMZP::docker
zinit snippet OMZP::bazel

# Theme
zinit ice as"theme"
zinit light dracula/zsh

# Heavy plugins — loaded asynchronously after prompt appears (turbo mode)
zinit wait lucid for \
  zsh-users/zsh-completions \
  atinit"zicompinit; zicdreplay" \
    zdharma-continuum/fast-syntax-highlighting \
  atload"_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions

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
