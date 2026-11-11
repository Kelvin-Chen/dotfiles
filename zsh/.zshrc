# Terminal fallback. Must run before anything reads $terminfo (key bindings,
# zle, the prompt).
#
# Terminals like kitty set TERM=xterm-kitty and rely on a terminfo entry that
# only exists where kitty is installed (it points $TERMINFO at its own app
# bundle). After ssh, sudo, `docker exec`, or inside a tmux server that
# outlived the terminal, that entry is gone and every curses program fails with
# "unknown terminal type". The same happens with tmux-256color on hosts with an
# old ncurses. An empty $terminfo means the lookup failed, so drop to an entry
# that exists everywhere. No forks: this costs nothing when TERM is fine.
if [[ -n "${TERM:-}" ]] && zmodload zsh/terminfo 2>/dev/null && (( ${#terminfo} == 0 )); then
  case "$TERM" in
    tmux*|screen*) export TERM=screen-256color ;;
    *)             export TERM=xterm-256color ;;
  esac
  # $terminfo is only re-read on assignment in interactive shells.
  if [[ -o interactive ]] && (( ${#terminfo} == 0 )); then
    export TERM="${TERM%-256color}"
  fi
fi

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
  # Byte-compile zinit itself. zinit compiles the plugins it manages but not
  # its own 3000-line entry point, which otherwise gets re-parsed by every
  # shell (~4ms). `source` picks up the .zwc automatically while it is newer
  # than the source, so a `zinit self-update` just triggers one recompile.
  if [[ ! -e "$ZINIT_HOME/zinit.zsh.zwc" || "$ZINIT_HOME/zinit.zsh" -nt "$ZINIT_HOME/zinit.zsh.zwc" ]]; then
    zcompile "$ZINIT_HOME/zinit.zsh" 2>/dev/null
  fi
  source "$ZINIT_HOME/zinit.zsh"

  # Answer `git version` from a cache while the eager plugins load.
  #
  # OMZP::git asks once and the dracula theme asks twice, purely to gate
  # features on git >= 2.8/2.13/2.14/2.30. Each ask is a fork+exec, and on
  # macOS /usr/bin/git is an xcrun shim that takes ~6ms — together these were
  # a third of startup. The cache is rewritten in the background once a day
  # (or right away if the git binary changed), so an upgrade is noticed by the
  # shell after next. The `git` function exists only until the theme has
  # loaded and passes everything except a bare `git version` straight through.
  () {
    emulate -L zsh
    (( $+commands[git] )) || return 0
    local dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
    local cache="$dir/git-version"
    typeset -g _git_version_line=
    [[ -r "$cache" ]] && _git_version_line="$(<$cache)"   # $(<file) does not fork
    if [[ "$_git_version_line" != "git version "* ]]; then
      # No (usable) cache yet: pay for the fork once.
      _git_version_line="$(command git version 2>/dev/null)"
      [[ -d "$dir" ]] || mkdir -p -- "$dir" 2>/dev/null
      print -r -- "$_git_version_line" >| "$cache" 2>/dev/null
    else
      local -a stale=( "$cache"(N.mh+24) )
      if (( ${#stale} )) || [[ "$commands[git]" -nt "$cache" ]]; then
        ( command git version >| "$cache.$$.new" 2>/dev/null &&
            mv -f -- "$cache.$$.new" "$cache" 2>/dev/null ||
            rm -f -- "$cache.$$.new" 2>/dev/null ) >/dev/null 2>&1 &!
      fi
    fi
  }
  if [[ "${_git_version_line:-}" == "git version "* ]] && (( ! $+functions[git] )); then
    _git_version_shim=1
    function git {
      if [[ $# -eq 1 && "$1" == version ]]; then
        print -r -- "$_git_version_line"
      else
        command git "$@"
      fi
    }
    # The theme's own probe is `$(git version | cut ...)` twice; even with the
    # function above that is two subshells and two `cut`s, so answer it here.
    if [[ -z "${DRACULA_GIT_NOLOCK:-}" ]]; then
      autoload -Uz is-at-least
      is-at-least 2.14 "${${(As: :)_git_version_line}[3]}" && DRACULA_GIT_NOLOCK=1 || DRACULA_GIT_NOLOCK=0
    fi
  fi
  # The theme forks `locale | grep` to choose a 12h/24h clock format even when
  # the clock segment is off (the default). Only let it when it is shown.
  (( ${DRACULA_DISPLAY_TIME:-0} )) || : "${DRACULA_TIME_FORMAT:=%-H:%M}"

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

  # Everything that asks for the git version at load time has loaded.
  (( ${_git_version_shim:-0} )) && unfunction git
  unset _git_version_line _git_version_shim

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
