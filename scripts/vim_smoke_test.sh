#!/usr/bin/env bash
# vim_smoke_test.sh — headless smoke test for the plugin-free vim fallback.
# Run from anywhere; it locates the repo root relative to itself.
#   bash scripts/vim_smoke_test.sh
# Overridable for local testing: VIMRC=..., VIM_BIN=..., REPO_ROOT=...
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${REPO_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"
cd "$REPO_ROOT" || { echo "cannot cd to repo root: $REPO_ROOT"; exit 1; }

VIMRC="${VIMRC:-vim/.vimrc}"
VIM_BIN="${VIM_BIN:-vim}"

PASS=0; FAIL=0
pass() { printf '  \033[32mPASS\033[0m %s\n' "$1"; PASS=$((PASS+1)); }
fail() { printf '  \033[31mFAIL\033[0m %s\n' "$1"; FAIL=$((FAIL+1)); }
warn() { printf '  \033[33mWARN\033[0m %s\n' "$1"; }
section() { printf '\n== %s ==\n' "$1"; }

# --- preconditions ---
section "Preconditions"
if ! command -v "$VIM_BIN" >/dev/null 2>&1; then
  fail "vim not found on PATH"
  printf '\nRESULT: FAIL (vim missing)\n'; exit 1
fi
pass "vim: $("$VIM_BIN" --version | head -1)"
if [ ! -f "$VIMRC" ]; then fail "vimrc not found: $VIMRC"; printf '\nRESULT: FAIL\n'; exit 1; fi
pass "vimrc present: $VIMRC"

# --- hermetic temp dir + isolated HOME (no side effects) ---
TMP="$(mktemp -d "${TMPDIR:-/tmp}/vim_smoke.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT
FAKE_HOME="$TMP/home"; mkdir -p "$FAKE_HOME"
MAPS="$TMP/maps.txt"; MSGS="$TMP/messages.txt"

# --- 1. headless load: zero errors, exit 0 ---
section "1. Headless load (no errors, exit 0)"
HOME="$FAKE_HOME" "$VIM_BIN" -u "$VIMRC" -i NONE -N -es \
  -c "redir! > $MSGS" -c 'silent messages' -c 'redir END' -c 'qa!' </dev/null
rc=$?
if [ "$rc" -eq 0 ]; then pass "vim exited 0"; else fail "vim exit code = $rc"; fi
if grep -Eq 'Error detected|^E[0-9]+:|^line +[0-9]+:' "$MSGS"; then
  fail "error messages during startup:"; sed 's/^/      | /' "$MSGS"
else
  pass "no error messages in :messages"
fi

# --- 2. keybinding parity ---
section "2. Keybinding parity (:map + :map!)"
HOME="$FAKE_HOME" "$VIM_BIN" -u "$VIMRC" -i NONE -N -es \
  -c "redir! > $MAPS" -c 'silent map' -c 'silent map!' -c 'redir END' -c 'qa!' </dev/null
assert_map() { if grep -Eq "$2" "$MAPS"; then pass "map: $1"; else fail "map MISSING: $1"; fi; }
assert_map "; -> :"               '[[:space:]];[[:space:]]'
assert_map "jk -> <Esc> (insert)" '[[:space:]]jk[[:space:]]'
assert_map "kj -> <Esc> (insert)" '[[:space:]]kj[[:space:]]'
assert_map "j -> gj"              '[[:space:]]j[[:space:]].*gj'
assert_map "k -> gk"              '[[:space:]]k[[:space:]].*gk'
assert_map "<C-h> window nav"     '[[:space:]]<C-H>[[:space:]]'
assert_map "<C-j> window nav"     '[[:space:]]<C-J>[[:space:]]'
assert_map "<C-k> window nav"     '[[:space:]]<C-K>[[:space:]]'
assert_map "<C-l> window nav"     '[[:space:]]<C-L>[[:space:]]'
assert_map "<leader>w save"       '[[:space:]]<Space>w[[:space:]]'
assert_map "<leader>cd"           '[[:space:]]<Space>cd[[:space:]]'
assert_map "<leader>tn new tab"   '[[:space:]]<Space>tn[[:space:]]'
assert_map "<leader>n explorer"   '[[:space:]]<Space>n[[:space:]]'
assert_map "<leader>f find"       '[[:space:]]<Space>f[[:space:]]'
if grep -Eiq '<Space>n[[:space:]].*(explore|netrw)' "$MAPS"; then
  pass "<leader>n resolves to netrw"
else
  fail "<leader>n RHS not netrw/:Explore"
fi
if grep -Eiq '<Space>f[[:space:]].*find' "$MAPS"; then
  pass "<leader>f resolves to :find"
else
  fail "<leader>f RHS not :find"
fi

# --- 3. no plugin artifacts in vimrc ---
section "3. No plugin/plugin-manager artifacts in $VIMRC"
ART_RE='plug#begin|plug#end|call plug|plug\.vim|PlugInstall|UpdateRemotePlugins|DoRemote|vim-plug|<Plug>|^[[:space:]]*Plug[[:space:]]|curl'
PLUG_RE='airline|catppuccin|ctrlp|nerdtree|nerdcommenter|NERDSpace|fugitive|gitgutter|tagbar|easymotion|easy-align|EasyAlign|delimitmate|multiple-cursors|tmuxline|vim-go|g:go_|GoRun|GoTest|python-mode|pymode|julia-vim|haskell-vim|g:haskell_|GhcMod|g:jsx_|g:tern_|yats|vim-sexp|g:sexp_|fireplace|async-clj-omni|vimtex|vim-markdown|vim-ruby|Dockerfile\.vim|nginx\.vim|haproxy'
hit=0
if grep -nEi "$ART_RE"  "$VIMRC"; then hit=1; fi
if grep -nEi "$PLUG_RE" "$VIMRC"; then hit=1; fi
if [ "$hit" -eq 0 ]; then pass "no artifacts found"; else fail "plugin artifacts present (see lines above)"; fi

# --- 4. make check ---
section "4. make check"
if make check >"$TMP/makecheck.log" 2>&1; then
  pass "make check exited 0"
else
  fail "make check failed:"; sed 's/^/      | /' "$TMP/makecheck.log"
fi

# --- 5. ftplugin files are plugin-free ---
section "5. ftplugin files are plugin-free"
if grep -REn "$PLUG_RE|g:pymode|GoRun|GoTest" vim/.vim/ftplugin/; then
  fail "plugin settings remain in ftplugin/*"
else
  pass "ftplugin/* contain only built-in settings"
fi

section "Summary"
printf '  passed: %d   failed: %d\n' "$PASS" "$FAIL"
if [ "$FAIL" -eq 0 ]; then
  printf '\nRESULT: \033[32mPASS\033[0m\n'; exit 0
else
  printf '\nRESULT: \033[31mFAIL\033[0m\n'; exit 1
fi
