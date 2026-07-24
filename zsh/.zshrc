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

  # Custom completions must join fpath before compinit runs (turbo block below).
  [[ -d "$HOME/.zsh/completions" ]] && fpath=("$HOME/.zsh/completions" $fpath)

  # Oh-my-zsh libs and plugins.
  #
  # These stay eager on purpose. zinit's turbo queue is drained one item per
  # prompt, so deferring these (~21ms total) would leave `gst`, `docker` and
  # friends undefined for the first several commands, and would push the
  # syntax highlighter and autosuggestions — which are queued behind them —
  # several prompts out.
  #
  # `light-mode` skips zinit's "investigation" pass, where it diffs the set of
  # functions/parameters/aliases/widgets before and after sourcing in order to
  # support `zinit report` and `zinit unload`. Neither is used here. Worth
  # ~15ms of median startup; `compdef` calls are still captured, so completions
  # are unaffected (verified: identical $#_comps with and without).
  zinit light-mode for \
    OMZL::clipboard.zsh \
    OMZL::completion.zsh \
    OMZL::history.zsh \
    OMZL::key-bindings.zsh \
    OMZP::git \
    OMZP::gnu-utils \
    OMZP::docker \
    OMZP::bazel

  # Theme — sets PROMPT, so it cannot be deferred.
  zinit ice as"theme"
  zinit light dracula/zsh

  # Heavy plugins — loaded asynchronously after prompt appears (turbo mode).
  # Keep this list short: everything queued here waits an extra prompt.
  #
  # This is also where compinit runs. /etc/zsh/zshrc already runs an audited
  # compinit before this file, but that happens before the fpath additions
  # above, so a second pass is required for them to be visible.
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

# Helper for sourcing config that lives on a network filesystem. Loaded before
# the machine-specific files below, which are its main callers.
[[ -r "$HOME/.zsh/lib/cached-source.zsh" ]] && source "$HOME/.zsh/lib/cached-source.zsh"

# Operating system specific configuration.
# $OSTYPE is a zsh built-in, so this avoids forking `uname` on every startup.
case "$OSTYPE" in
  darwin*)
    [[ -r "$HOME/.zshrc_mac" ]] && source "$HOME/.zshrc_mac"
    ;;
  linux*)
    [[ -r "$HOME/.zshrc_linux" ]] && source "$HOME/.zshrc_linux"
    ;;
esac

# Source aliases
[[ -r "$HOME/.aliases" ]] && source "$HOME/.aliases"

# Source machine specific configuration
LOCAL_ZSHRC="$HOME/.zshrc_local"
[[ -r "$LOCAL_ZSHRC" ]] && source "$LOCAL_ZSHRC"
