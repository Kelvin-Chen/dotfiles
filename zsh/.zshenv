export LANG=en_US.UTF-8
export COLORTERM=truecolor

export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

export EDITOR=nvim
export GIT_EDITOR=$EDITOR

export PAGER=less

export NVM_LAZY_LOAD=true
export NVM_COMPLETION=true
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

# Set Android paths if $ANDROID_HOME is set
if [[ -n "$ANDROID_HOME" ]]; then
    export PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin"
fi

export FZF_DEFAULT_OPTS='--height 60% --layout=reverse --border'

# Source machine specific configuration
LOCAL_ZSHENV="$HOME/.zshenv_local"
test -f "$LOCAL_ZSHENV" || touch "$LOCAL_ZSHENV"
source "$LOCAL_ZSHENV"
