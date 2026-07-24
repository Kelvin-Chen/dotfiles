#!/usr/bin/env bash
# cached_source_test.sh — hermetic tests for zsh/.zsh/lib/cached-source.zsh.
#
# cached_source trades freshness for startup speed: it sources a local copy of
# a file that lives on a slow network filesystem and refreshes that copy in a
# detached background job. These tests pin down that contract:
#
#   - the first call populates the cache and sources it
#   - a fresh cache is used even when the source has since changed
#   - a stale cache is still served immediately, and refreshed for next time
#   - a missing source with no cache fails quietly rather than erroring
#
#   bash scripts/cached_source_test.sh
# Overridable for local testing: LIB=..., ZSH_BIN=...
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${REPO_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"
LIB="${LIB:-$REPO_ROOT/zsh/.zsh/lib/cached-source.zsh}"
ZSH_BIN="${ZSH_BIN:-zsh}"

PASS=0; FAIL=0
pass() { printf '  \033[32mPASS\033[0m %s\n' "$1"; PASS=$((PASS+1)); }
fail() { printf '  \033[31mFAIL\033[0m %s\n' "$1"; FAIL=$((FAIL+1)); }
section() { printf '\n== %s ==\n' "$1"; }

if ! command -v "$ZSH_BIN" >/dev/null 2>&1; then
  echo "zsh not found; skipping."; exit 0
fi
if [ ! -f "$LIB" ]; then
  fail "lib not found: $LIB"; printf '\nRESULT: FAIL\n'; exit 1
fi

TMP="$(mktemp -d "${TMPDIR:-/tmp}/cached_source.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT

SRC="$TMP/remote/config.zsh"
mkdir -p "$TMP/remote"
CACHE_DIR="$TMP/cache/zsh"
CACHE="$CACHE_DIR/${SRC//\//_}"

# run <extra-zsh-code> : load the lib in a hermetic zsh and report $MARKER.
run() {
  XDG_CACHE_HOME="$TMP/cache" "$ZSH_BIN" -f -c "
    source '$LIB'
    $1
    print -r -- \"MARKER=\${MARKER:-none}\"
  " 2>&1
}

assert_marker() {
  local label="$1" out="$2" want="$3"
  if printf '%s\n' "$out" | grep -qF "MARKER=$want"; then
    pass "$label"
  else
    fail "$label (wanted MARKER=$want)"
    printf '%s\n' "$out" | sed 's/^/      | /'
  fi
}

section "1. First call populates the cache and sources it"
printf 'MARKER=v1\n' > "$SRC"
OUT="$(run "cached_source '$SRC'")"
assert_marker "sources the file" "$OUT" "v1"
if [ -r "$CACHE" ]; then pass "cache file created"; else fail "cache file created"; fi

section "2. A fresh cache is preferred over a changed source"
printf 'MARKER=v2\n' > "$SRC"
OUT="$(run "cached_source '$SRC'")"
assert_marker "serves cached copy, not the updated source" "$OUT" "v1"

section "3. A stale cache is served now, then refreshed for next time"
touch -d '2 hours ago' "$CACHE"
OUT="$(run "cached_source '$SRC'; sleep 1")"
assert_marker "stale cache still served immediately" "$OUT" "v1"
OUT="$(run "cached_source '$SRC'")"
assert_marker "next shell picks up the refreshed copy" "$OUT" "v2"

section "4. Refresh is atomic (no partial temp files left behind)"
leftovers="$(find "$CACHE_DIR" -name '*.new' 2>/dev/null | wc -l | tr -d ' ')"
if [ "$leftovers" = "0" ]; then
  pass "no .new temp files left in cache dir"
else
  fail "no .new temp files left in cache dir (found $leftovers)"
fi

section "5. Missing source with no cache fails quietly"
OUT="$(run "cached_source '$TMP/remote/absent.zsh' && print -r -- UNEXPECTED_OK")"
if printf '%s\n' "$OUT" | grep -qF "UNEXPECTED_OK"; then
  fail "returns non-zero for a missing source"
else
  pass "returns non-zero for a missing source"
fi
if printf '%s\n' "$OUT" | grep -Eq "no such file|not found|parse error"; then
  fail "stays quiet for a missing source"
  printf '%s\n' "$OUT" | sed 's/^/      | /'
else
  pass "stays quiet for a missing source"
fi

section "Summary"
printf '  passed: %d   failed: %d\n' "$PASS" "$FAIL"
if [ "$FAIL" -gt 0 ]; then printf '\nRESULT: FAIL\n'; exit 1; fi
printf '\nRESULT: PASS\n'
