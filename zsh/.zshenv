export LANG="${LANG:-en_US.UTF-8}"
export COLORTERM="${COLORTERM:-truecolor}"

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

typeset -U path PATH
path=(
    "$HOME/.local/bin"
    "$HOME/bin"
    "$HOME/.cargo/bin"
    /opt/homebrew/bin
    /usr/local/bin
    /usr/bin
    /bin
    /usr/sbin
    /sbin
    $path
)
export PATH

export EDITOR="${EDITOR:-nvim}"
export GIT_EDITOR="${GIT_EDITOR:-$EDITOR}"

export PAGER="${PAGER:-less}"

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

# Set Android paths if $ANDROID_HOME is set
if [[ -n "${ANDROID_HOME:-}" ]]; then
    path+=("$ANDROID_HOME/platform-tools" "$ANDROID_HOME/tools" "$ANDROID_HOME/tools/bin")
    export PATH
fi

: "${FZF_DEFAULT_OPTS:=--height 60% --layout=reverse --border}"
export FZF_DEFAULT_OPTS

# Source machine specific configuration
LOCAL_ZSHENV="$HOME/.zshenv_local"
[[ -r "$LOCAL_ZSHENV" ]] && source "$LOCAL_ZSHENV"
