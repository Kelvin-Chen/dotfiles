# vi:ft=zsh
#
# cached_source <path> [max_age_hours]
#
# Source <path> through a local copy kept under $XDG_CACHE_HOME/zsh.
#
# Intended for shell config that lives on a network filesystem — Piper
# (/google/src/head/...), x20, or /google/data/ro/... Reading those costs tens
# of milliseconds on every shell start, and stalls for several hundred whenever
# the FUSE attribute cache revalidates, which shows up as a shell that is
# usually fast but occasionally takes most of a second to appear.
#
# Tradeoff: the copy is refreshed by a detached background job, so an edit to
# the source file takes effect in the *next* shell, not the current one. Pass a
# max_age_hours of 0 to refresh on every start (still in the background).
#
# Returns non-zero if the file could be neither cached nor read, so callers can
# fall back or stay quiet on machines where the path does not exist.
cached_source() {
  emulate -L zsh
  setopt local_options no_nomatch

  local src="$1" max_age="${2:-1}"
  local dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
  # Flatten the absolute path into a single filename so two sources can never
  # collide on basename alone (e.g. several different files named "bashrc").
  local cache="$dir/${src//\//_}"

  if [[ ! -r "$cache" ]]; then
    # Nothing cached yet: pay the network cost once, synchronously.
    [[ -r "$src" ]] || return 1
    [[ -d "$dir" ]] || mkdir -p -- "$dir" || return 1
    cp -f -- "$src" "$cache" 2>/dev/null || return 1
  else
    local -a stale
    (( max_age == 0 )) || stale=( "$cache"(N.mh+${max_age}) )
    if (( max_age == 0 )) || (( ${#stale} )); then
      # Refresh detached so it never blocks the prompt. Write to a
      # pid-qualified temp and rename, so a shell starting mid-refresh can
      # never source a half-written file.
      ( cp -f -- "$src" "$cache.$$.new" 2>/dev/null &&
          mv -f -- "$cache.$$.new" "$cache" 2>/dev/null ||
          rm -f -- "$cache.$$.new" 2>/dev/null ) >/dev/null 2>&1 &!
    fi
  fi

  source "$cache"
}
