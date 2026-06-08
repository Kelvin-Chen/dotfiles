#!/usr/bin/env bash
# zsh_smoke_test.sh — hermetic, cross-platform smoke test for zsh/.zshrc.
#
# Runs the real zsh/.zshrc inside a throwaway $HOME with a stubbed zinit (no
# network) under several simulated environments and asserts it loads cleanly.
#
# The headline regression it guards against: some environments (e.g. Google
# corp Linux) pre-define `npm`/`npx` as aliases. zsh expands an alias while
# *reading* a same-named function definition, so `npm() { ... }` becomes a
# parse error ("defining function based on alias `npm'"). This only reproduces
# when the alias exists *before* .zshrc is sourced, which is exactly what we
# simulate here.
#
#   bash scripts/zsh_smoke_test.sh
# Overridable for local testing: ZSHRC=..., ZSH_BIN=..., REPO_ROOT=...
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${REPO_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"
cd "$REPO_ROOT" || { echo "cannot cd to repo root: $REPO_ROOT"; exit 1; }

ZSHRC="${ZSHRC:-$REPO_ROOT/zsh/.zshrc}"
ZSH_BIN="${ZSH_BIN:-zsh}"

PASS=0; FAIL=0
pass() { printf '  \033[32mPASS\033[0m %s\n' "$1"; PASS=$((PASS+1)); }
fail() { printf '  \033[31mFAIL\033[0m %s\n' "$1"; FAIL=$((FAIL+1)); }
section() { printf '\n== %s ==\n' "$1"; }

# --- preconditions ---
section "Preconditions"
if ! command -v "$ZSH_BIN" >/dev/null 2>&1; then
  fail "zsh not found on PATH"
  printf '\nRESULT: FAIL (zsh missing)\n'; exit 1
fi
pass "zsh: $("$ZSH_BIN" --version)"
if [ ! -f "$ZSHRC" ]; then fail "zshrc not found: $ZSHRC"; printf '\nRESULT: FAIL\n'; exit 1; fi
pass "zshrc present: $ZSHRC"

# --- hermetic temp dir (no side effects) ---
TMP="$(mktemp -d "${TMPDIR:-/tmp}/zsh_smoke.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT

# A driver run inside zsh: optionally pre-defines corp-style aliases (so they
# exist *before* .zshrc is read), sources .zshrc, then reports resolved names.
DRIVER="$TMP/driver.zsh"
cat > "$DRIVER" <<'EOF'
[[ -n "${PRESET_NPM_ALIASES:-}" ]] && { alias npm='gpkg npm'; alias npx='gpkg npx'; }
source "$1"
[[ -n "${INVOKE_NPM:-}" ]] && npm hello
print -r -- "WHENCE npm=$(whence -w npm 2>/dev/null)"
print -r -- "WHENCE npx=$(whence -w npx 2>/dev/null)"
print -r -- "WHENCE node=$(whence -w node 2>/dev/null)"
print -r -- "WHENCE nvm=$(whence -w nvm 2>/dev/null)"
print -r -- "OS_RC=${OS_RC_LOADED:-none}"
EOF

# build_home <name> [nvm] [os: linux|mac]
#   Creates a hermetic fake $HOME with a no-op zinit stub (so no network clone),
#   optionally a fake nvm install, and a fake `uname` returning the chosen OS
#   along with the matching ~/.zshrc_<os> marker file. Echoes the home path.
build_home() {
  local name="$1" want_nvm="${2:-}" os="${3:-linux}"
  local home="$TMP/$name"
  mkdir -p "$home/.local/share/zinit/zinit.git" "$home/bin"
  # No-op zinit so every `zinit ...` call in .zshrc is a harmless no-op.
  printf 'zinit() { : }\n' > "$home/.local/share/zinit/zinit.git/zinit.zsh"

  # Fake `uname` to exercise the OS case statement deterministically.
  local uname_out="Linux"; [[ "$os" == "mac" ]] && uname_out="Darwin"
  cat > "$home/bin/uname" <<EOF2
#!/bin/sh
echo "$uname_out"
EOF2
  chmod +x "$home/bin/uname"

  # OS-specific rc files leave a marker we can assert on.
  printf 'export OS_RC_LOADED=linux\n' > "$home/.zshrc_linux"
  printf 'export OS_RC_LOADED=mac\n'   > "$home/.zshrc_mac"

  if [[ -n "$want_nvm" ]]; then
    mkdir -p "$home/.nvm"
    # When the lazy-load shim sources this, it replaces the shims with "real"
    # nvm-provided commands that echo a recognizable marker.
    cat > "$home/.nvm/nvm.sh" <<'EOF3'
nvm()  { echo "NVM_REAL $*"; }
node() { echo "NODE_REAL $*"; }
npm()  { echo "NPM_REAL $*"; }
npx()  { echo "NPX_REAL $*"; }
EOF3
  fi
  printf '%s' "$home"
}

# run_zshrc <home> : source .zshrc hermetically; honors PRESET_NPM_ALIASES /
# INVOKE_NPM from the environment. Stdout+stderr captured by caller.
run_zshrc() {
  local home="$1"
  HOME="$home" XDG_DATA_HOME="$home/.local/share" \
    NVM_DIR="$home/.nvm" \
    PATH="$home/bin:$PATH" \
    "$ZSH_BIN" -f "$DRIVER" "$ZSHRC" 2>&1
}

clean_load() { # assert no parse / alias-clash errors in captured output
  local label="$1" out="$2"
  if printf '%s' "$out" | grep -Eq "parse error|defining function based on alias"; then
    fail "$label: errors during load:"
    printf '%s\n' "$out" | grep -E "parse error|defining function based on alias" | sed 's/^/      | /'
  else
    pass "$label: no parse / alias-clash errors"
  fi
}
assert_line() { # assert captured output contains an exact RESULT line
  local label="$1" out="$2" needle="$3"
  if printf '%s\n' "$out" | grep -qF "$needle"; then
    pass "$label"
  else
    fail "$label (missing: $needle)"
    printf '%s\n' "$out" | sed 's/^/      | /'
  fi
}

# --- 1. static syntax check ---
section "1. Static syntax (zsh -n)"
if "$ZSH_BIN" -n "$ZSHRC" 2>"$TMP/syntax.err"; then
  pass "zsh -n exited 0"
else
  fail "zsh -n reported syntax errors:"; sed 's/^/      | /' "$TMP/syntax.err"
fi

# --- 2. REGRESSION: corp npm/npx aliases + nvm installed ---
# This is the exact scenario that broke on Linux. Without the fix it prints
# "defining function based on alias `npm'" + "parse error near `()'".
section "2. Regression: pre-set npm/npx aliases + nvm present (Linux)"
H="$(build_home reg nvm linux)"
OUT="$(PRESET_NPM_ALIASES=1 run_zshrc "$H")"
clean_load   "alias+nvm" "$OUT"
assert_line  "npm is a function (shim installed, alias dropped)"  "$OUT" "WHENCE npm=npm: function"
assert_line  "npx is a function (shim installed, alias dropped)"  "$OUT" "WHENCE npx=npx: function"
assert_line  "node is a function (shim installed)"                "$OUT" "WHENCE node=node: function"
assert_line  "nvm is a function (shim installed)"                 "$OUT" "WHENCE nvm=nvm: function"

# --- 3. corp aliases preserved when nvm is NOT installed ---
section "3. No nvm: pre-set npm/npx aliases are preserved (Linux)"
H="$(build_home noenvm "" linux)"
OUT="$(PRESET_NPM_ALIASES=1 run_zshrc "$H")"
clean_load   "alias-only" "$OUT"
assert_line  "npm remains an alias (corp shortcut intact)"  "$OUT" "WHENCE npm=npm: alias"
assert_line  "npx remains an alias (corp shortcut intact)"  "$OUT" "WHENCE npx=npx: alias"

# --- 4. nvm lazy-load actually dispatches to the real command ---
section "4. Lazy-load: first npm call sources nvm and dispatches"
H="$(build_home lazy nvm linux)"
OUT="$(PRESET_NPM_ALIASES=1 INVOKE_NPM=1 run_zshrc "$H")"
clean_load   "lazy-load" "$OUT"
assert_line  "calling npm sources nvm and runs the real npm" "$OUT" "NPM_REAL hello"

# --- 5. cross-platform OS branch dispatch ---
section "5. OS branch dispatch (uname case statement)"
H="$(build_home linux_os "" linux)"
OUT="$(run_zshrc "$H")"
clean_load  "linux branch" "$OUT"
assert_line "Linux sources ~/.zshrc_linux" "$OUT" "OS_RC=linux"

H="$(build_home mac_os "" mac)"
OUT="$(run_zshrc "$H")"
clean_load  "darwin branch" "$OUT"
assert_line "Darwin sources ~/.zshrc_mac" "$OUT" "OS_RC=mac"

section "Summary"
printf '  passed: %d   failed: %d\n' "$PASS" "$FAIL"
if [ "$FAIL" -eq 0 ]; then
  printf '\nRESULT: \033[32mPASS\033[0m\n'; exit 0
else
  printf '\nRESULT: \033[31mFAIL\033[0m\n'; exit 1
fi
