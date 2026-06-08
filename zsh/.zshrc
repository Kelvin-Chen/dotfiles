# Bootstrap zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -r "$ZINIT_HOME/zinit.zsh" ]]; then
  if command -v git &>/dev/null; then
    mkdir -p "$(dirname "$ZINIT_HOME")"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
  else
    print -u2 "WARNING: git not found; skipping zinit bootstrap."
  fi
fi

if [[ -r "$ZINIT_HOME/zinit.zsh" ]]; then
  source "$ZINIT_HOME/zinit.zsh"

  #####################
  #      Plugins
  #####################

  # Oh-my-zsh libs
  zinit snippet OMZL::clipboard.zsh
  [[ -d "$HOME/.zsh/completions" ]] && fpath=("$HOME/.zsh/completions" $fpath)
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
else
  print -u2 "WARNING: zinit not available; skipping zsh plugins."
fi

# NVM — lazy load on first use to avoid startup overhead, but only when installed.
NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
# Some environments (e.g. Google corp Linux) pre-define `npm`/`npx` as aliases.
# zsh alias-expands while *reading* a same-named function definition, so the
# shims below are a parse error whenever those aliases exist — and zsh reads
# (and thus expands) the whole if-block even when the condition is false.
# Disable alias expansion just while this block is read, then restore it. This
# is a standalone command so it takes effect before the block is parsed.
unsetopt aliases
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  # nvm is installed, so its commands should win: drop any clashing aliases so
  # the lazy-load shims (functions) are what actually run.
  unalias nvm node npm npx 2>/dev/null
  _nvm_load() {
    source "$NVM_DIR/nvm.sh"
    [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
  }
  nvm()  { unfunction nvm; _nvm_load; nvm "$@"; }
  node() { unfunction node npm npx; _nvm_load; node "$@"; }
  npm()  { unfunction node npm npx; _nvm_load; npm "$@"; }
  npx()  { unfunction node npm npx; _nvm_load; npx "$@"; }
fi
setopt aliases

# Operating system specific configuration.
case "$(uname -s)" in
  Darwin)
    [[ -r "$HOME/.zshrc_mac" ]] && source "$HOME/.zshrc_mac"
    ;;
  Linux*)
    [[ -r "$HOME/.zshrc_linux" ]] && source "$HOME/.zshrc_linux"
    ;;
esac

# Source aliases
[[ -r "$HOME/.aliases" ]] && source "$HOME/.aliases"

# Source machine specific configuration
LOCAL_ZSHRC="$HOME/.zshrc_local"
[[ -r "$LOCAL_ZSHRC" ]] && source "$LOCAL_ZSHRC"
